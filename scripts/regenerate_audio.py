#!/usr/bin/env python3
"""
Regenerate audio files for lessons with correct character voice profiles.
Uses Azure TTS API with voice profiles from characters.json.
"""

import os
import sys
import json
import time
import requests
from pathlib import Path

# Azure TTS configuration
AZURE_KEY = os.environ.get("AZURE_TTS_KEY")
if not AZURE_KEY:
    print("Error: AZURE_TTS_KEY environment variable is not set")
    print("Please set it before running: export AZURE_TTS_KEY='your-key-here'")
    sys.exit(1)
AZURE_REGION = "eastus"
AZURE_ENDPOINT = f"https://{AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1"

# Project paths
PROJECT_ROOT = Path(__file__).parent.parent
CHARACTERS_FILE = PROJECT_ROOT / "assets" / "data" / "characters.json"
LESSONS_DIR = PROJECT_ROOT / "assets" / "data" / "lessons"
AUDIO_OUTPUT_DIR = PROJECT_ROOT / "assets" / "audio" / "lessons"

# Languages to generate
LANGUAGES = ["en", "ru", "de", "fr", "it", "am", "my"]


def load_characters():
    """Load character voice profiles from characters.json"""
    with open(CHARACTERS_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return {char['characterId']: char for char in data['characters']}


def load_lesson(lesson_file):
    """Load lesson from JSON file"""
    with open(lesson_file, 'r', encoding='utf-8') as f:
        return json.load(f)


def get_voice_profile(characters, character_id, language):
    """Get voice profile for a character and language"""
    if character_id not in characters:
        print(f"  Warning: Unknown character '{character_id}', using orson defaults")
        character_id = 'orson'

    char = characters[character_id]
    profiles = char.get('voiceProfiles', {})

    if language not in profiles:
        print(f"  Warning: No profile for {character_id}/{language}, using en")
        language = 'en'

    return profiles.get(language, profiles.get('en', {}))


def build_ssml(text, voice_profile, tone=None):
    """Build SSML for Azure TTS with voice profile"""
    voice_name = voice_profile.get('voiceName', 'en-US-JennyNeural')
    base_pitch = voice_profile.get('basePitch', 0)
    base_rate = voice_profile.get('baseRate', 1.0)
    style = voice_profile.get('defaultStyle')
    style_degree = voice_profile.get('defaultStyleDegree', 1.0)
    role = voice_profile.get('role')

    # Convert pitch to percentage string
    if isinstance(base_pitch, int):
        pitch_str = f"+{base_pitch}%" if base_pitch >= 0 else f"{base_pitch}%"
    else:
        pitch_str = str(base_pitch)

    # Convert rate to relative percentage (0.9 -> "-10%", 1.2 -> "+20%")
    rate_percent = round((base_rate - 1.0) * 100)
    rate_str = f"+{rate_percent}%" if rate_percent >= 0 else f"{rate_percent}%"

    # Build prosody attributes
    prosody_attrs = f'pitch="{pitch_str}" rate="{rate_str}"'

    # Build express-as if style is specified
    if style:
        style_degree_str = f' styledegree="{style_degree}"' if style_degree != 1.0 else ''
        express_open = f'<mstts:express-as style="{style}"{style_degree_str}>'
        express_close = '</mstts:express-as>'
    else:
        express_open = ''
        express_close = ''

    # Build role attribute if specified
    role_attr = f' role="{role}"' if role else ''

    ssml = f'''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="http://www.w3.org/2001/mstts"
       xml:lang="en-US">
    <voice name="{voice_name}"{role_attr}>
        {express_open}
        <prosody {prosody_attrs}>
            {text}
        </prosody>
        {express_close}
    </voice>
</speak>'''

    return ssml


def synthesize_speech(ssml, output_path):
    """Call Azure TTS API to synthesize speech"""
    headers = {
        'Ocp-Apim-Subscription-Key': AZURE_KEY,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
        'User-Agent': 'ElliFriendsApp'
    }

    try:
        response = requests.post(AZURE_ENDPOINT, headers=headers, data=ssml.encode('utf-8'))

        if response.status_code == 200:
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, 'wb') as f:
                f.write(response.content)
            return True
        elif response.status_code == 429:
            print(f"  Rate limited, waiting 30s...")
            time.sleep(30)
            return synthesize_speech(ssml, output_path)
        else:
            print(f"  Error {response.status_code}: {response.text[:200]}")
            return False
    except Exception as e:
        print(f"  Exception: {e}")
        return False


def process_lesson(lesson_file, characters, languages, force=False):
    """Process a lesson file and generate audio for all languages"""
    lesson = load_lesson(lesson_file)
    lesson_id = lesson['id']
    scenes = lesson['scenes']

    print(f"\n{'='*60}")
    print(f"Processing lesson: {lesson_id}")
    print(f"{'='*60}")

    for lang in languages:
        print(f"\n  Language: {lang}")

        for scene_index, scene in enumerate(scenes):
            # Skip scenes without dialogue
            dialogue = scene.get('dialogue')
            if not dialogue:
                continue

            # Get text for this language
            text = dialogue.get(lang)
            if not text:
                print(f"    Scene {scene_index}: No text for {lang}, skipping")
                continue

            # Get character and voice profile
            character = scene.get('character', 'orson')
            voice_profile = get_voice_profile(characters, character, lang)
            tone = scene.get('tone')

            # Output path
            output_path = AUDIO_OUTPUT_DIR / lesson_id / lang / f"scene_{scene_index}.mp3"

            # Skip if exists and not forcing
            if output_path.exists() and not force:
                print(f"    Scene {scene_index}: Already exists, skipping")
                continue

            # Build SSML and synthesize
            ssml = build_ssml(text, voice_profile, tone)

            print(f"    Scene {scene_index}: {character} -> {voice_profile.get('voiceName', 'unknown')}")

            if synthesize_speech(ssml, output_path):
                print(f"      Saved: {output_path.name}")
            else:
                print(f"      FAILED!")

            # Small delay to avoid rate limiting
            time.sleep(0.3)


def main():
    # Parse arguments
    force = '--force' in sys.argv
    specific_lesson = None
    specific_lang = None

    for arg in sys.argv[1:]:
        if arg.startswith('--lesson='):
            specific_lesson = arg.split('=')[1]
        elif arg.startswith('--lang='):
            specific_lang = arg.split('=')[1]

    # Load characters
    print("Loading character voice profiles...")
    characters = load_characters()
    print(f"  Loaded {len(characters)} characters")

    # Determine languages to process
    languages = [specific_lang] if specific_lang else LANGUAGES
    print(f"  Languages: {', '.join(languages)}")

    # Find lesson files
    if specific_lesson:
        lesson_files = [LESSONS_DIR / f"lesson_{specific_lesson}.json"]
    else:
        lesson_files = sorted(LESSONS_DIR.glob("lesson_*.json"))

    print(f"  Found {len(lesson_files)} lesson files")

    # Process each lesson
    for lesson_file in lesson_files:
        if not lesson_file.exists():
            print(f"Lesson file not found: {lesson_file}")
            continue
        process_lesson(lesson_file, characters, languages, force)

    print("\n" + "="*60)
    print("Audio generation complete!")
    print("="*60)


if __name__ == '__main__':
    main()
