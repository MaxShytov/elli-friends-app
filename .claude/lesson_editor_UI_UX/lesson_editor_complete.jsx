import React, { useState } from 'react';

// ==================== DESIGN SYSTEM ====================
const colors = {
  primary: '#4CAF50',
  primaryDark: '#388E3C',
  primaryLight: '#C8E6C9',
  secondary: '#9370DB',      // Orson purple
  secondaryLight: '#E1D5F5',
  tertiary: '#FFD700',       // Merv yellow
  tertiaryLight: '#FFF8E1',
  surface: '#FFFFFF',
  background: '#F5F5F5',
  error: '#D32F2F',
  errorLight: '#FFEBEE',
  warning: '#FFA000',
  warningLight: '#FFF3E0',
  success: '#4CAF50',
  successLight: '#E8F5E9',
  info: '#2196F3',
  infoLight: '#E3F2FD',
  onPrimary: '#FFFFFF',
  onSurface: '#1C1B1F',
  onSurfaceVariant: '#49454F',
  outline: '#79747E',
  outlineVariant: '#CAC4D0',
  surfaceVariant: '#E7E0EC',
  surfaceContainer: '#F3EDF7',
};

const shadows = {
  sm: '0 1px 2px rgba(0,0,0,0.1)',
  md: '0 2px 8px rgba(0,0,0,0.12)',
  lg: '0 4px 16px rgba(0,0,0,0.15)',
};

// ==================== REUSABLE COMPONENTS ====================
const AppBar = ({ title, onBack, actions, subtitle }) => (
  <div style={{
    backgroundColor: colors.primary,
    padding: '16px 20px',
    display: 'flex',
    alignItems: 'center',
    gap: 16,
    boxShadow: shadows.md
  }}>
    {onBack && (
      <button onClick={onBack} style={{
        background: 'none', border: 'none', color: 'white', fontSize: 24, cursor: 'pointer', padding: 0
      }}>←</button>
    )}
    <div style={{ flex: 1 }}>
      <span style={{ color: 'white', fontSize: 20, fontWeight: 600 }}>{title}</span>
      {subtitle && <div style={{ color: 'rgba(255,255,255,0.8)', fontSize: 12, marginTop: 2 }}>{subtitle}</div>}
    </div>
    {actions}
  </div>
);

const Button = ({ children, variant = 'filled', color = colors.primary, onClick, style, icon }) => {
  const baseStyle = {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    padding: '12px 24px',
    borderRadius: 24,
    fontSize: 14,
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'all 0.2s',
    border: 'none',
  };
  
  const variants = {
    filled: { backgroundColor: color, color: 'white' },
    outlined: { backgroundColor: 'transparent', border: `1px solid ${color}`, color },
    text: { backgroundColor: 'transparent', color },
    tonal: { backgroundColor: colors.surfaceVariant, color: colors.onSurface },
  };
  
  return (
    <button onClick={onClick} style={{ ...baseStyle, ...variants[variant], ...style }}>
      {icon && <span>{icon}</span>}
      {children}
    </button>
  );
};

const Card = ({ children, selected, onClick, style }) => (
  <div
    onClick={onClick}
    style={{
      backgroundColor: colors.surface,
      borderRadius: 16,
      border: `2px solid ${selected ? colors.primary : colors.outlineVariant}`,
      boxShadow: selected ? shadows.md : shadows.sm,
      cursor: onClick ? 'pointer' : 'default',
      transition: 'all 0.2s',
      ...style
    }}
  >
    {children}
  </div>
);

const Chip = ({ label, selected, onClick, icon, color = colors.primary }) => (
  <button
    onClick={onClick}
    style={{
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      padding: '8px 16px',
      borderRadius: 20,
      border: `1px solid ${selected ? color : colors.outline}`,
      backgroundColor: selected ? color : 'white',
      color: selected ? 'white' : colors.onSurface,
      fontSize: 13,
      fontWeight: selected ? 600 : 400,
      cursor: 'pointer',
    }}
  >
    {icon && <span>{icon}</span>}
    {label}
  </button>
);

const TextField = ({ label, value, onChange, placeholder, multiline, rows = 3, error, helper }) => (
  <div style={{ marginBottom: 16 }}>
    {label && (
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 8, color: colors.onSurface }}>
        {label}
      </label>
    )}
    {multiline ? (
      <textarea
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        rows={rows}
        style={{
          width: '100%',
          padding: 12,
          borderRadius: 8,
          border: `1px solid ${error ? colors.error : colors.outline}`,
          fontSize: 14,
          resize: 'vertical',
          boxSizing: 'border-box',
        }}
      />
    ) : (
      <input
        type="text"
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        style={{
          width: '100%',
          padding: 12,
          borderRadius: 8,
          border: `1px solid ${error ? colors.error : colors.outline}`,
          fontSize: 14,
          boxSizing: 'border-box',
        }}
      />
    )}
    {(error || helper) && (
      <div style={{ fontSize: 12, marginTop: 4, color: error ? colors.error : colors.outline }}>
        {error || helper}
      </div>
    )}
  </div>
);

const Select = ({ label, value, options, onChange }) => (
  <div style={{ marginBottom: 16 }}>
    {label && (
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 8, color: colors.onSurface }}>
        {label}
      </label>
    )}
    <select
      value={value}
      onChange={onChange}
      style={{
        width: '100%',
        padding: 12,
        borderRadius: 8,
        border: `1px solid ${colors.outline}`,
        fontSize: 14,
        backgroundColor: 'white',
      }}
    >
      {options.map(opt => (
        <option key={opt.value} value={opt.value}>{opt.label}</option>
      ))}
    </select>
  </div>
);

const Tabs = ({ tabs, activeTab, onTabChange }) => (
  <div style={{ display: 'flex', borderBottom: `1px solid ${colors.outlineVariant}` }}>
    {tabs.map(tab => (
      <button
        key={tab.id}
        onClick={() => onTabChange(tab.id)}
        style={{
          flex: 1,
          padding: '14px 8px',
          border: 'none',
          borderBottom: `3px solid ${activeTab === tab.id ? colors.primary : 'transparent'}`,
          backgroundColor: 'transparent',
          color: activeTab === tab.id ? colors.primary : colors.outline,
          fontWeight: activeTab === tab.id ? 600 : 400,
          cursor: 'pointer',
          fontSize: 13,
        }}
      >
        {tab.icon && <span style={{ marginRight: 6 }}>{tab.icon}</span>}
        {tab.label}
      </button>
    ))}
  </div>
);

const Badge = ({ type, children }) => {
  const typeStyles = {
    error: { bg: colors.errorLight, color: colors.error },
    warning: { bg: colors.warningLight, color: colors.warning },
    success: { bg: colors.successLight, color: colors.success },
    info: { bg: colors.infoLight, color: colors.info },
    default: { bg: colors.surfaceVariant, color: colors.onSurface },
  };
  const style = typeStyles[type] || typeStyles.default;
  
  return (
    <span style={{
      display: 'inline-flex',
      alignItems: 'center',
      padding: '4px 10px',
      borderRadius: 12,
      backgroundColor: style.bg,
      color: style.color,
      fontSize: 11,
      fontWeight: 600,
    }}>
      {children}
    </span>
  );
};

// ==================== SCREEN 1: LESSONS LIST ====================
const LessonsListScreen = ({ onNavigate }) => {
  const lessons = [
    { id: 1, title: 'Counting 1-5', scenes: 12, status: 'complete', languages: 7, lastEdit: '2 hours ago' },
    { id: 2, title: 'Colors', scenes: 8, status: 'draft', languages: 5, lastEdit: 'Yesterday' },
    { id: 3, title: 'Shapes', scenes: 15, status: 'review', languages: 3, lastEdit: '3 days ago' },
    { id: 4, title: 'Letters A-E', scenes: 0, status: 'new', languages: 0, lastEdit: 'Just created' },
  ];

  const statusBadge = (status) => {
    const config = {
      complete: { type: 'success', label: '✓ Complete' },
      draft: { type: 'warning', label: '📝 Draft' },
      review: { type: 'info', label: '👀 Review' },
      new: { type: 'default', label: '🆕 New' },
    };
    return <Badge type={config[status].type}>{config[status].label}</Badge>;
  };

  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar 
        title="Lesson Editor"
        subtitle="Elli & Friends"
        actions={
          <Button variant="filled" onClick={() => onNavigate('settings')} style={{ padding: '8px 16px' }}>
            ⚙️ Settings
          </Button>
        }
      />

      {/* Stats Bar */}
      <div style={{ 
        display: 'flex', 
        gap: 16, 
        padding: '16px 20px',
        backgroundColor: colors.surface,
        borderBottom: `1px solid ${colors.outlineVariant}`
      }}>
        {[
          { label: 'Lessons', value: '4', icon: '📚' },
          { label: 'Scenes', value: '35', icon: '🎬' },
          { label: 'Languages', value: '7', icon: '🌐' },
        ].map(stat => (
          <div key={stat.label} style={{ flex: 1, textAlign: 'center' }}>
            <div style={{ fontSize: 24, marginBottom: 4 }}>{stat.icon}</div>
            <div style={{ fontSize: 20, fontWeight: 700, color: colors.primary }}>{stat.value}</div>
            <div style={{ fontSize: 12, color: colors.outline }}>{stat.label}</div>
          </div>
        ))}
      </div>

      {/* Search & Filter */}
      <div style={{ padding: '16px 20px', display: 'flex', gap: 12 }}>
        <input
          type="text"
          placeholder="🔍 Search lessons..."
          style={{
            flex: 1,
            padding: '12px 16px',
            borderRadius: 24,
            border: `1px solid ${colors.outline}`,
            fontSize: 14,
          }}
        />
        <Button variant="tonal" style={{ padding: '12px 16px' }}>
          🔽 Filter
        </Button>
      </div>

      {/* Lessons List */}
      <div style={{ flex: 1, overflow: 'auto', padding: '0 20px 20px' }}>
        {lessons.map(lesson => (
          <Card
            key={lesson.id}
            onClick={() => onNavigate('main')}
            style={{ padding: 16, marginBottom: 12 }}
          >
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
              <div style={{
                width: 56,
                height: 56,
                borderRadius: 12,
                backgroundColor: colors.primaryLight,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 28
              }}>
                📖
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                  <span style={{ fontSize: 16, fontWeight: 600 }}>{lesson.title}</span>
                  {statusBadge(lesson.status)}
                </div>
                <div style={{ fontSize: 13, color: colors.outline, marginBottom: 8 }}>
                  {lesson.scenes} scenes • {lesson.languages}/7 languages
                </div>
                <div style={{ fontSize: 12, color: colors.outline }}>
                  Last edited: {lesson.lastEdit}
                </div>
              </div>
              <span style={{ color: colors.outline, fontSize: 20 }}>→</span>
            </div>
          </Card>
        ))}
      </div>

      {/* FAB */}
      <button
        onClick={() => onNavigate('newLesson')}
        style={{
          position: 'fixed',
          bottom: 24,
          right: 24,
          width: 64,
          height: 64,
          borderRadius: 20,
          backgroundColor: colors.primary,
          color: 'white',
          border: 'none',
          fontSize: 28,
          cursor: 'pointer',
          boxShadow: shadows.lg,
        }}
      >
        +
      </button>
    </div>
  );
};

// ==================== SCREEN 2: NEW LESSON ====================
const NewLessonScreen = ({ onNavigate }) => {
  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Create New Lesson" onBack={() => onNavigate('lessons')} />

      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        <Card style={{ padding: 20, marginBottom: 20 }}>
          <h3 style={{ margin: '0 0 16px', fontSize: 18 }}>📝 Lesson Details</h3>
          
          <TextField label="Lesson Title" placeholder="e.g., Counting 1-10" />
          <TextField label="Description" placeholder="Brief description of the lesson..." multiline rows={3} />
          
          <Select 
            label="Topic"
            options={[
              { value: 'counting', label: '🔢 Counting' },
              { value: 'letters', label: '🔤 Letters' },
              { value: 'colors', label: '🎨 Colors' },
              { value: 'shapes', label: '⬡ Shapes' },
            ]}
          />
          
          <Select 
            label="Difficulty"
            options={[
              { value: 'easy', label: '🟢 Easy (3-4 years)' },
              { value: 'medium', label: '🟡 Medium (4-5 years)' },
              { value: 'hard', label: '🔴 Hard (5-7 years)' },
            ]}
          />
        </Card>

        <Card style={{ padding: 20, marginBottom: 20 }}>
          <h3 style={{ margin: '0 0 16px', fontSize: 18 }}>🌐 Languages</h3>
          <p style={{ fontSize: 13, color: colors.outline, marginBottom: 12 }}>Select languages for this lesson:</p>
          
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {[
              { code: 'en', flag: '🇬🇧', name: 'English', default: true },
              { code: 'ru', flag: '🇷🇺', name: 'Russian' },
              { code: 'fr', flag: '🇫🇷', name: 'French' },
              { code: 'de', flag: '🇩🇪', name: 'German' },
              { code: 'it', flag: '🇮🇹', name: 'Italian' },
              { code: 'my', flag: '🇲🇲', name: 'Myanmar' },
              { code: 'am', flag: '🇪🇹', name: 'Amharic' },
            ].map(lang => (
              <Chip
                key={lang.code}
                label={`${lang.flag} ${lang.name}`}
                selected={lang.default || lang.code === 'fr'}
                onClick={() => {}}
              />
            ))}
          </div>
        </Card>

        <Card style={{ padding: 20 }}>
          <h3 style={{ margin: '0 0 16px', fontSize: 18 }}>🏷️ Tags</h3>
          <TextField placeholder="Add tags separated by comma..." helper="e.g., numbers, math, basic" />
        </Card>
      </div>

      <div style={{ padding: 20, backgroundColor: colors.surface, borderTop: `1px solid ${colors.outlineVariant}` }}>
        <div style={{ display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('lessons')} style={{ flex: 1 }}>
            Cancel
          </Button>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Create Lesson
          </Button>
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 3: MAIN EDITOR (HORIZONTAL TIMELINE) ====================
const MainEditorScreen = ({ onNavigate }) => {
  const [selectedScene, setSelectedScene] = useState(3);
  const [activeTab, setActiveTab] = useState('dialogue');
  
  const scenes = [
    { id: 1, type: 'dialogue', character: 'orson', emotion: '😊', text: 'Hi! I\'m Orson!', duration: 4, transition: 'auto_tts', hasError: false },
    { id: 2, type: 'pause', duration: 2, transition: 'auto_timer', hasError: false },
    { id: 3, type: 'dialogue', character: 'orson', emotion: '😃', text: 'Let\'s count butterflies!', duration: 5, animals: [{ emoji: '🦋', count: 3 }], transition: 'auto_tts', hasError: false },
    { id: 4, type: 'question', character: 'orson', emotion: '🤔', text: 'How many butterflies?', options: ['2', '3', '4'], correct: 1, transition: 'task', hasError: false },
    { id: 5, type: 'celebration', character: 'orson', emotion: '🎉', text: 'Great job!', duration: 3, transition: 'auto_tts', hasError: false },
    { id: 6, type: 'dialogue', character: 'orson', emotion: '😊', text: '', duration: 4, transition: 'auto_tts', hasError: true, errorMsg: 'Missing dialogue text' },
  ];

  const getSceneTypeConfig = (type) => {
    const configs = {
      dialogue: { color: colors.secondary, icon: '💬' },
      pause: { color: colors.outline, icon: '⏸️' },
      question: { color: colors.warning, icon: '❓' },
      celebration: { color: colors.success, icon: '🎉' },
    };
    return configs[type] || configs.dialogue;
  };

  const getTransitionIcon = (transition) => {
    const icons = { auto_tts: '🎤', auto_timer: '⏱️', button: '👆', task: '❓' };
    return icons[transition] || '→';
  };

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: colors.background }}>
      {/* App Bar */}
      <AppBar
        title="Counting 1-5"
        subtitle="12 scenes • Draft"
        onBack={() => onNavigate('lessons')}
        actions={
          <div style={{ display: 'flex', gap: 8 }}>
            <Button variant="text" onClick={() => onNavigate('validation')} style={{ color: 'white', padding: '8px 12px' }}>
              ⚠️ 1
            </Button>
            <Button variant="text" onClick={() => onNavigate('preview')} style={{ color: 'white', padding: '8px 12px' }}>
              ▶️ Preview
            </Button>
            <Button variant="filled" color="white" onClick={() => {}} style={{ color: colors.primary, padding: '8px 16px' }}>
              💾 Save
            </Button>
          </div>
        }
      />

      {/* Toolbar */}
      <div style={{
        backgroundColor: colors.surface,
        padding: '8px 12px',
        display: 'flex',
        gap: 6,
        borderBottom: `1px solid ${colors.outlineVariant}`,
        overflowX: 'auto',
        flexShrink: 0
      }}>
        {[
          { icon: '⚙️', label: 'Lesson Settings', action: 'lessonSettings' },
          { icon: '📤', label: 'Export', action: 'export' },
          { icon: '📥', label: 'Import', action: 'import' },
          { icon: '↩️', label: 'Undo', action: 'history' },
          { icon: '⌨️', label: 'Shortcuts', action: 'shortcuts' },
        ].map(item => (
          <button
            key={item.label}
            onClick={() => onNavigate(item.action)}
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 2,
              padding: '6px 12px',
              borderRadius: 8,
              border: 'none',
              backgroundColor: colors.surfaceVariant,
              cursor: 'pointer',
              fontSize: 10,
              color: colors.onSurface,
              whiteSpace: 'nowrap'
            }}
          >
            <span style={{ fontSize: 16 }}>{item.icon}</span>
            {item.label}
          </button>
        ))}
      </div>

      {/* Horizontal Scene Timeline */}
      <div style={{
        backgroundColor: colors.surface,
        borderBottom: `1px solid ${colors.outlineVariant}`,
        padding: '12px 0',
        flexShrink: 0
      }}>
        <div style={{ display: 'flex', alignItems: 'center', padding: '0 16px', marginBottom: 10 }}>
          <span style={{ fontSize: 14, fontWeight: 600 }}>📋 Scenes</span>
          <span style={{ marginLeft: 8, fontSize: 12, color: colors.outline }}>{scenes.length} total</span>
          <button 
            onClick={() => onNavigate('templates')}
            style={{
              marginLeft: 'auto',
              backgroundColor: colors.primary,
              color: 'white',
              border: 'none',
              borderRadius: 16,
              padding: '6px 14px',
              fontSize: 12,
              fontWeight: 600,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 4
            }}
          >
            ➕ Add Scene
          </button>
        </div>
        
        <div style={{ 
          display: 'flex', 
          gap: 8, 
          overflowX: 'auto', 
          padding: '0 16px 8px',
          scrollSnapType: 'x mandatory'
        }}>
          {scenes.map((scene, idx) => {
            const config = getSceneTypeConfig(scene.type);
            const isSelected = selectedScene === scene.id;
            
            return (
              <div key={scene.id} style={{ scrollSnapAlign: 'start' }}>
                <div
                  onClick={() => setSelectedScene(scene.id)}
                  style={{
                    minWidth: 100,
                    padding: '10px 12px',
                    borderRadius: 12,
                    backgroundColor: isSelected ? colors.surfaceVariant : 'white',
                    border: `2px solid ${isSelected ? colors.primary : scene.hasError ? colors.error : colors.outlineVariant}`,
                    cursor: 'pointer',
                    transition: 'all 0.2s'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                    <span style={{
                      backgroundColor: config.color,
                      color: 'white',
                      borderRadius: 10,
                      width: 20,
                      height: 20,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: 10,
                      fontWeight: 600
                    }}>
                      {idx + 1}
                    </span>
                    <span style={{ fontSize: 16 }}>{scene.emotion || config.icon}</span>
                    {scene.hasError && <span style={{ marginLeft: 'auto' }}>⚠️</span>}
                  </div>
                  <div style={{ fontSize: 11, fontWeight: 500, color: colors.onSurface, marginBottom: 2 }}>
                    {scene.type === 'pause' ? 'Pause' : scene.character}
                  </div>
                  <div style={{ fontSize: 10, color: colors.outline }}>
                    {getTransitionIcon(scene.transition)} {scene.duration}s
                  </div>
                </div>
                
                {/* Branching indicator for questions */}
                {scene.type === 'question' && (
                  <div style={{
                    marginTop: 4,
                    padding: '4px 8px',
                    backgroundColor: colors.warningLight,
                    borderRadius: 6,
                    fontSize: 9,
                    color: colors.warning,
                    textAlign: 'center'
                  }}>
                    ↳ ✓ → {idx + 2} | ✗ → Retry
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Scene Editor - Full Width */}
      <div style={{ flex: 1, overflow: 'auto', padding: 12 }}>
        <SceneEditorPanel 
          scene={scenes.find(s => s.id === selectedScene)} 
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          onNavigate={onNavigate}
        />
      </div>
    </div>
  );
};

// ==================== SCENE EDITOR PANEL ====================
const SceneEditorPanel = ({ scene, activeTab, setActiveTab, onNavigate }) => {
  if (!scene) return null;

  const tabs = [
    { id: 'dialogue', label: 'Dialogue', icon: '💬' },
    { id: 'character', label: 'Character', icon: '🐾' },
    { id: 'objects', label: 'Objects', icon: '🦋' },
    { id: 'timeline', label: 'Timeline', icon: '⏱️' },
    { id: 'settings', label: 'Settings', icon: '⚙️' },
  ];

  return (
    <Card style={{ overflow: 'hidden' }}>
      {/* Scene Header */}
      <div style={{ 
        backgroundColor: colors.surfaceContainer, 
        padding: '16px 20px',
        display: 'flex',
        alignItems: 'center',
        gap: 12
      }}>
        <span style={{ fontSize: 36 }}>{scene.emotion || '📝'}</span>
        <div style={{ flex: 1 }}>
          <h3 style={{ margin: 0, fontSize: 18 }}>
            Scene {scene.id}: {scene.type === 'pause' ? 'Pause' : scene.character || 'New'}
          </h3>
          <p style={{ margin: '4px 0 0', fontSize: 13, color: colors.outline }}>
            Duration: {scene.duration}s • {scene.type} • {scene.transition}
          </p>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <Button variant="tonal" onClick={() => onNavigate('scenePreview')} icon="▶️">
            Preview
          </Button>
          <Button variant="tonal" onClick={() => onNavigate('contextMenu')} icon="⋯" style={{ padding: '12px' }} />
        </div>
      </div>

      {/* Error Banner */}
      {scene.hasError && (
        <div style={{
          backgroundColor: colors.errorLight,
          padding: '12px 20px',
          display: 'flex',
          alignItems: 'center',
          gap: 8,
          borderBottom: `1px solid ${colors.error}`,
        }}>
          <span>⚠️</span>
          <span style={{ fontSize: 13, color: colors.error, flex: 1 }}>{scene.errorMsg}</span>
          <Button variant="text" color={colors.error} style={{ padding: '4px 8px', fontSize: 12 }}>Fix</Button>
        </div>
      )}

      {/* Tabs */}
      <Tabs tabs={tabs} activeTab={activeTab} onTabChange={setActiveTab} />

      {/* Tab Content */}
      <div style={{ padding: 20 }}>
        {activeTab === 'dialogue' && <DialogueTabContent scene={scene} onNavigate={onNavigate} />}
        {activeTab === 'character' && <CharacterTabContent scene={scene} onNavigate={onNavigate} />}
        {activeTab === 'objects' && <ObjectsTabContent scene={scene} onNavigate={onNavigate} />}
        {activeTab === 'timeline' && <SceneTimelineTabContent scene={scene} onNavigate={onNavigate} />}
        {activeTab === 'settings' && <SettingsTabContent scene={scene} onNavigate={onNavigate} />}
      </div>
    </Card>
  );
};

// ==================== DIALOGUE TAB ====================
const DialogueTabContent = ({ scene, onNavigate }) => (
  <div>
    <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
      <Select 
        label="Primary Language"
        options={[
          { value: 'en', label: '🇬🇧 English' },
          { value: 'ru', label: '🇷🇺 Russian' },
          { value: 'fr', label: '🇫🇷 French' },
        ]}
      />
      <Button 
        variant="tonal" 
        onClick={() => onNavigate('localization')}
        style={{ alignSelf: 'flex-end', marginBottom: 16 }}
        icon="🌐"
      >
        All Languages
      </Button>
    </div>
    
    <TextField 
      label="Dialogue Text"
      value={scene.text || ''}
      placeholder="Enter what the character says..."
      multiline
      rows={4}
      error={!scene.text ? 'Dialogue text is required' : null}
    />
    
    <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
      <Button variant="tonal" icon="🔊" onClick={() => onNavigate('ttsPreview')}>
        TTS Preview
      </Button>
      <Button variant="filled" color={colors.secondary} icon="🤖" onClick={() => onNavigate('translate')}>
        Auto-Translate
      </Button>
      <Button variant="tonal" icon="📊" onClick={() => onNavigate('ttsDuration')}>
        Duration Check
      </Button>
    </div>

    <div style={{ marginBottom: 16 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Voice Tone</label>
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        {[
          { id: 'friendly', label: '🙂 Friendly', selected: true },
          { id: 'excited', label: '😄 Excited' },
          { id: 'questioning', label: '🤔 Questioning' },
          { id: 'encouraging', label: '😊 Encouraging' },
          { id: 'surprised', label: '😮 Surprised' },
        ].map(tone => (
          <Chip key={tone.id} label={tone.label} selected={tone.selected} onClick={() => {}} />
        ))}
      </div>
    </div>

    <TextField 
      label="Translation Context"
      placeholder="e.g., Keep it short, playful tone, this is a greeting..."
      helper="Instructions for translators to maintain correct tone and meaning"
    />
  </div>
);

// ==================== CHARACTER TAB ====================
const CharacterTabContent = ({ scene, onNavigate }) => (
  <div>
    <div style={{ marginBottom: 24 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Character</label>
      <div style={{ display: 'flex', gap: 12 }}>
        {[
          { id: 'orson', name: 'Orson', emoji: '🐱', color: colors.secondary },
          { id: 'merv', name: 'Merv', emoji: '🐻', color: colors.tertiary },
          { id: 'narrator', name: 'Narrator', emoji: '🎙️', color: colors.outline },
        ].map(char => (
          <Card
            key={char.id}
            selected={scene.character === char.id}
            onClick={() => {}}
            style={{ flex: 1, padding: 16, textAlign: 'center' }}
          >
            <div style={{
              width: 60,
              height: 60,
              borderRadius: 30,
              backgroundColor: char.color,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 8px',
              fontSize: 32
            }}>
              {char.emoji}
            </div>
            <div style={{ fontWeight: 600 }}>{char.name}</div>
          </Card>
        ))}
      </div>
    </div>

    <div style={{ marginBottom: 24 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Emotion</label>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
        {[
          { id: 'neutral', emoji: '😐', label: 'Neutral' },
          { id: 'happy', emoji: '😊', label: 'Happy', selected: true },
          { id: 'sad', emoji: '😢', label: 'Sad' },
          { id: 'crying', emoji: '😭', label: 'Crying' },
          { id: 'angry', emoji: '😠', label: 'Angry' },
          { id: 'thinking', emoji: '🤔', label: 'Thinking' },
          { id: 'excited', emoji: '😃', label: 'Excited' },
          { id: 'pleading', emoji: '🥺', label: 'Pleading' },
        ].map(emo => (
          <Card
            key={emo.id}
            selected={emo.selected}
            onClick={() => {}}
            style={{ padding: 12, textAlign: 'center' }}
          >
            <div style={{ fontSize: 28, marginBottom: 4 }}>{emo.emoji}</div>
            <div style={{ fontSize: 11 }}>{emo.label}</div>
          </Card>
        ))}
      </div>
    </div>

    <div style={{ marginBottom: 24 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Animation</label>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8 }}>
        {[
          { id: 'idle', icon: '🧍', label: 'Idle', selected: true },
          { id: 'wave', icon: '👋', label: 'Wave' },
          { id: 'walk', icon: '🚶', label: 'Walk' },
          { id: 'happy', icon: '💃', label: 'Happy Dance' },
          { id: 'sad', icon: '😿', label: 'Sad' },
          { id: 'talk', icon: '🗣️', label: 'Talking' },
        ].map(anim => (
          <Card
            key={anim.id}
            selected={anim.selected}
            onClick={() => {}}
            style={{ padding: 14, textAlign: 'center' }}
          >
            <div style={{ fontSize: 24, marginBottom: 4 }}>{anim.icon}</div>
            <div style={{ fontSize: 11 }}>{anim.label}</div>
          </Card>
        ))}
      </div>
    </div>

    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
      <div>
        <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 8 }}>Entrance Effect</label>
        <Button variant="tonal" onClick={() => onNavigate('animationPicker')} style={{ width: '100%', justifyContent: 'space-between' }}>
          <span>🎬 Fade In</span>
          <span>→</span>
        </Button>
      </div>
      <div>
        <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 8 }}>Exit Effect</label>
        <Button variant="tonal" onClick={() => onNavigate('animationPicker')} style={{ width: '100%', justifyContent: 'space-between' }}>
          <span>🎬 Fly Out Right</span>
          <span>→</span>
        </Button>
      </div>
    </div>

    <div style={{ marginTop: 16 }}>
      <Button variant="outlined" onClick={() => onNavigate('positioning')} icon="📍" style={{ width: '100%' }}>
        Position Character on Screen
      </Button>
    </div>
  </div>
);

// ==================== OBJECTS TAB ====================
const ObjectsTabContent = ({ scene, onNavigate }) => (
  <div>
    {/* Existing Objects */}
    <div style={{ marginBottom: 20 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>
        Objects in Scene ({scene.animals?.length || 0})
      </label>
      
      {scene.animals?.map((animal, idx) => (
        <Card key={idx} style={{ padding: 12, marginBottom: 8 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span style={{ fontSize: 36 }}>{animal.emoji}</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 600 }}>Butterfly × {animal.count}</div>
              <div style={{ fontSize: 12, color: colors.outline }}>
                flutter • fade in → fly out right
              </div>
            </div>
            <Button variant="tonal" onClick={() => onNavigate('objectEditor')} style={{ padding: 8 }}>✏️</Button>
            <Button variant="tonal" color={colors.error} style={{ padding: 8 }}>🗑️</Button>
          </div>
        </Card>
      )) || (
        <div style={{ 
          padding: 24, 
          textAlign: 'center', 
          backgroundColor: colors.surfaceContainer,
          borderRadius: 12,
          color: colors.outline
        }}>
          No objects added yet
        </div>
      )}
    </div>

    {/* Quick Add */}
    <div style={{ marginBottom: 20 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Quick Add</label>
      
      <div style={{ marginBottom: 12 }}>
        <div style={{ fontSize: 12, color: colors.outline, marginBottom: 8 }}>🐾 Animals</div>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {[
            { emoji: '🦋', label: 'Butterfly', animation: 'flutter' },
            { emoji: '🐟', label: 'Fish', animation: 'swim' },
            { emoji: '🐵', label: 'Monkey', animation: 'swing_down' },
            { emoji: '🐢', label: 'Turtle', animation: 'walk_slow' },
            { emoji: '🐸', label: 'Frog', animation: 'hop' },
            { emoji: '🐦', label: 'Bird', animation: 'fly' },
          ].map(obj => (
            <button
              key={obj.emoji}
              onClick={() => onNavigate('objectEditor')}
              style={{
                padding: '10px 14px',
                borderRadius: 12,
                border: `1px solid ${colors.outline}`,
                backgroundColor: 'white',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: 6
              }}
            >
              <span style={{ fontSize: 20 }}>{obj.emoji}</span>
              <span style={{ fontSize: 12 }}>{obj.label}</span>
            </button>
          ))}
        </div>
      </div>
      
      <div style={{ marginBottom: 12 }}>
        <div style={{ fontSize: 12, color: colors.outline, marginBottom: 8 }}>🍎 Items</div>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {[
            { emoji: '🍎', label: 'Apple', animation: 'fall_from_tree' },
            { emoji: '🍌', label: 'Banana', animation: 'roll_in' },
            { emoji: '🍊', label: 'Orange' },
            { emoji: '🍃', label: 'Leaf', animation: 'wave_in_breeze' },
            { emoji: '🌸', label: 'Flower' },
            { emoji: '🌰', label: 'Pinecone' },
          ].map(obj => (
            <button
              key={obj.emoji}
              onClick={() => onNavigate('objectEditor')}
              style={{
                padding: '10px 14px',
                borderRadius: 12,
                border: `1px solid ${colors.outline}`,
                backgroundColor: 'white',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: 6
              }}
            >
              <span style={{ fontSize: 20 }}>{obj.emoji}</span>
              <span style={{ fontSize: 12 }}>{obj.label}</span>
            </button>
          ))}
        </div>
      </div>
      
      <div>
        <div style={{ fontSize: 12, color: colors.outline, marginBottom: 8 }}>📋 Other</div>
        <div style={{ display: 'flex', gap: 8 }}>
          <button
            onClick={() => onNavigate('objectEditor')}
            style={{
              padding: '10px 14px',
              borderRadius: 12,
              border: `1px solid ${colors.outline}`,
              backgroundColor: 'white',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 6
            }}
          >
            <span style={{ fontSize: 20 }}>📋</span>
            <span style={{ fontSize: 12 }}>Number Board</span>
          </button>
          <button
            onClick={() => onNavigate('objectEditor')}
            style={{
              padding: '10px 14px',
              borderRadius: 12,
              border: `1px solid ${colors.outline}`,
              backgroundColor: 'white',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 6
            }}
          >
            <span style={{ fontSize: 20 }}>🔤</span>
            <span style={{ fontSize: 12 }}>Letter Board</span>
          </button>
        </div>
      </div>
    </div>

    <Button variant="outlined" onClick={() => onNavigate('animations')} icon="🎬" style={{ width: '100%' }}>
      Browse Animation Library
    </Button>
  </div>
);

// ==================== SCENE TIMELINE TAB ====================
const SceneTimelineTabContent = ({ scene, onNavigate }) => {
  const tracks = [
    { id: 'orson', label: 'Orson', color: colors.secondary, segments: [
      { start: 0, end: 0.5, type: 'entrance', label: 'Fade In' },
      { start: 0.5, end: 4.5, type: 'active', label: 'Talking' },
      { start: 4.5, end: 5, type: 'exit', label: 'Fade Out' },
    ]},
    { id: 'butterflies', label: 'Butterflies', color: colors.tertiary, segments: [
      { start: 1, end: 1.5, type: 'entrance', label: 'Fly In Left' },
      { start: 1.5, end: 4, type: 'active', label: 'Flutter' },
      { start: 4, end: 4.5, type: 'exit', label: 'Fly Out Right' },
    ]},
    { id: 'dialogue', label: 'Dialogue', color: colors.primary, segments: [
      { start: 0.5, end: 3, type: 'tts', label: 'TTS: "Let\'s count..."' },
    ]},
    { id: 'audio', label: 'Audio', color: colors.info, segments: [
      { start: 0, end: 5, type: 'ambient', label: 'Jungle Ambience' },
      { start: 1.5, end: 2, type: 'sfx', label: 'Flutter SFX' },
    ]},
  ];

  const totalDuration = 5;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
        <h4 style={{ margin: 0, fontSize: 14 }}>Scene Timeline</h4>
        <div style={{ display: 'flex', gap: 8 }}>
          <Button variant="tonal" onClick={() => onNavigate('scenePreview')} icon="▶️" style={{ padding: '6px 12px', fontSize: 12 }}>
            Play
          </Button>
          <span style={{ 
            backgroundColor: colors.surfaceVariant, 
            padding: '6px 12px', 
            borderRadius: 16,
            fontSize: 12,
            fontWeight: 600
          }}>
            {totalDuration}s
          </span>
        </div>
      </div>

      {/* Time ruler */}
      <div style={{ 
        display: 'flex', 
        marginBottom: 8,
        marginLeft: 100,
        fontSize: 10,
        color: colors.outline
      }}>
        {[0, 1, 2, 3, 4, 5].map(t => (
          <div key={t} style={{ flex: 1, textAlign: 'left' }}>{t}s</div>
        ))}
      </div>

      {/* Tracks */}
      <div style={{ marginBottom: 16 }}>
        {tracks.map(track => (
          <div key={track.id} style={{ display: 'flex', alignItems: 'center', marginBottom: 8 }}>
            <div style={{ 
              width: 100, 
              fontSize: 12, 
              fontWeight: 500,
              paddingRight: 8,
              textAlign: 'right'
            }}>
              {track.label}
            </div>
            <div style={{ 
              flex: 1, 
              height: 32, 
              backgroundColor: colors.surfaceVariant, 
              borderRadius: 4,
              position: 'relative',
              overflow: 'hidden'
            }}>
              {track.segments.map((seg, idx) => (
                <div
                  key={idx}
                  onClick={() => onNavigate('segmentEditor')}
                  style={{
                    position: 'absolute',
                    left: `${(seg.start / totalDuration) * 100}%`,
                    width: `${((seg.end - seg.start) / totalDuration) * 100}%`,
                    height: '100%',
                    backgroundColor: track.color,
                    opacity: seg.type === 'entrance' || seg.type === 'exit' ? 0.6 : 0.9,
                    borderRadius: 4,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 10,
                    color: 'white',
                    cursor: 'pointer',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                    padding: '0 4px'
                  }}
                >
                  {seg.label}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* Playhead */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
        <span style={{ fontSize: 12, width: 100, textAlign: 'right' }}>Current:</span>
        <input type="range" min="0" max={totalDuration} step="0.1" defaultValue="2.5" style={{ flex: 1 }} />
        <span style={{ fontSize: 12, fontWeight: 600 }}>2.5s</span>
      </div>

      {/* Legend */}
      <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
        {[
          { type: 'entrance', label: 'Entrance', opacity: 0.6 },
          { type: 'active', label: 'Active', opacity: 0.9 },
          { type: 'exit', label: 'Exit', opacity: 0.6 },
        ].map(item => (
          <div key={item.type} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 11 }}>
            <div style={{ 
              width: 16, 
              height: 16, 
              borderRadius: 4, 
              backgroundColor: colors.secondary,
              opacity: item.opacity
            }} />
            {item.label}
          </div>
        ))}
      </div>
    </div>
  );
};

// ==================== SETTINGS TAB ====================
const SettingsTabContent = ({ scene, onNavigate }) => (
  <div>
    {/* Transition Type */}
    <div style={{ marginBottom: 24 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>
        Transition Type
      </label>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
        {[
          { id: 'auto_tts', icon: '🎤', label: 'After TTS', desc: 'Wait for speech', selected: scene.transition === 'auto_tts' },
          { id: 'auto_timer', icon: '⏱️', label: 'Timer', desc: 'Fixed duration', selected: scene.transition === 'auto_timer' },
          { id: 'button', icon: '👆', label: 'Button', desc: 'User taps', selected: scene.transition === 'button' },
          { id: 'task', icon: '❓', label: 'Question', desc: 'Wait for answer', selected: scene.transition === 'task' },
        ].map(trans => (
          <Card
            key={trans.id}
            selected={trans.selected}
            onClick={() => {}}
            style={{ padding: 14 }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
              <span style={{ fontSize: 20 }}>{trans.icon}</span>
              <span style={{ fontWeight: 600, fontSize: 14 }}>{trans.label}</span>
            </div>
            <span style={{ fontSize: 11, color: colors.outline }}>{trans.desc}</span>
          </Card>
        ))}
      </div>
    </div>

    {/* Duration */}
    <div style={{ marginBottom: 24 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 8 }}>
        Duration / Pause After (seconds)
      </label>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <input type="range" min="1" max="10" step="0.5" defaultValue={scene.duration} style={{ flex: 1 }} />
        <span style={{ 
          backgroundColor: colors.surfaceVariant, 
          padding: '8px 16px', 
          borderRadius: 8,
          fontWeight: 600,
          minWidth: 50,
          textAlign: 'center'
        }}>{scene.duration}s</span>
      </div>
      <p style={{ fontSize: 11, color: colors.outline, marginTop: 4 }}>Default pause: 3 seconds</p>
    </div>

    {/* Question Settings */}
    {scene.type === 'question' && (
      <Card style={{ padding: 16, marginBottom: 24, backgroundColor: colors.warningLight }}>
        <h4 style={{ margin: '0 0 12px', fontSize: 14 }}>❓ Question Settings</h4>
        <Button variant="filled" color={colors.warning} onClick={() => onNavigate('questionEditor')} style={{ width: '100%' }}>
          Edit Question & Answers
        </Button>
      </Card>
    )}

    {/* Background */}
    <div style={{ marginBottom: 24 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Background</label>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
        {[
          { id: 'jungle_morning', label: '🌅 Jungle Morning', selected: true },
          { id: 'jungle_evening', label: '🌙 Jungle Evening' },
        ].map(bg => (
          <Card
            key={bg.id}
            selected={bg.selected}
            onClick={() => {}}
            style={{ padding: 14, textAlign: 'center' }}
          >
            {bg.label}
          </Card>
        ))}
      </div>
    </div>

    {/* Sound Effects */}
    <div style={{ marginBottom: 24 }}>
      <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Sound Effects</label>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {[
          { id: 'jungle_ambience', label: '🎵 Jungle Ambience', checked: true },
          { id: 'pop', label: '💥 Pop' },
          { id: 'flutter', label: '🦋 Flutter', checked: true },
          { id: 'hop', label: '🐸 Hop' },
          { id: 'roll', label: '🎱 Roll' },
        ].map(sfx => (
          <label key={sfx.id} style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: 10,
            padding: '10px 12px',
            borderRadius: 8,
            backgroundColor: sfx.checked ? colors.primaryLight : colors.surfaceContainer,
            cursor: 'pointer'
          }}>
            <input type="checkbox" defaultChecked={sfx.checked} />
            <span style={{ fontSize: 14 }}>{sfx.label}</span>
          </label>
        ))}
      </div>
    </div>

    {/* Button Settings */}
    {scene.transition === 'button' && (
      <TextField 
        label="Button Text"
        placeholder="e.g., Continue, Next, Let's Go!"
        helper="Text shown on the button"
      />
    )}
  </div>
);

// ==================== SCREEN 4: SCENE TEMPLATES ====================
const SceneTemplatesScreen = ({ onNavigate }) => {
  const templates = [
    { id: 'greeting', icon: '👋', label: 'Greeting', desc: 'Character waves and says hello', color: colors.primary, popular: true },
    { id: 'counting', icon: '🔢', label: 'Counting', desc: 'Show objects and count them', color: colors.secondary, popular: true },
    { id: 'question', icon: '❓', label: 'Question', desc: 'Multiple choice question', color: colors.warning },
    { id: 'celebration', icon: '🎉', label: 'Celebration', desc: 'Celebrate correct answer', color: colors.success },
    { id: 'pause', icon: '⏸️', label: 'Pause', desc: 'Silent pause between scenes', color: colors.outline },
    { id: 'intro', icon: '🎬', label: 'Introduction', desc: 'Lesson introduction', color: colors.info },
    { id: 'example', icon: '💡', label: 'Example', desc: 'Show an example', color: colors.tertiary },
    { id: 'custom', icon: '✏️', label: 'Custom', desc: 'Start from scratch', color: colors.onSurface },
  ];

  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Add New Scene" onBack={() => onNavigate('main')} />

      <div style={{ padding: '16px 20px', backgroundColor: colors.surface, borderBottom: `1px solid ${colors.outlineVariant}` }}>
        <p style={{ margin: 0, color: colors.outline, fontSize: 14 }}>Choose a template to get started:</p>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 12 }}>
          {templates.map(tmpl => (
            <Card
              key={tmpl.id}
              onClick={() => onNavigate('main')}
              style={{ padding: 20, textAlign: 'center', position: 'relative' }}
            >
              {tmpl.popular && (
                <Badge type="success" style={{ position: 'absolute', top: 8, right: 8 }}>
                  Popular
                </Badge>
              )}
              <div style={{
                width: 56,
                height: 56,
                borderRadius: 28,
                backgroundColor: tmpl.color,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 12px',
                fontSize: 28
              }}>
                {tmpl.icon}
              </div>
              <div style={{ fontWeight: 600, fontSize: 15, marginBottom: 4 }}>{tmpl.label}</div>
              <div style={{ fontSize: 12, color: colors.outline }}>{tmpl.desc}</div>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 5: OBJECT EDITOR ====================
const ObjectEditorScreen = ({ onNavigate }) => {
  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Edit Object" subtitle="🦋 Butterfly" onBack={() => onNavigate('main')} />

      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        {/* Preview */}
        <Card style={{ padding: 20, marginBottom: 20, textAlign: 'center' }}>
          <div style={{ fontSize: 80, marginBottom: 12 }}>🦋</div>
          <Button variant="tonal" onClick={() => onNavigate('positioning')} icon="📍">
            Position on Screen
          </Button>
        </Card>

        {/* Count */}
        <Card style={{ padding: 16, marginBottom: 16 }}>
          <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Count</label>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <button style={{ 
              width: 48, height: 48, borderRadius: 24, 
              border: `1px solid ${colors.outline}`, 
              backgroundColor: 'white',
              fontSize: 24,
              cursor: 'pointer'
            }}>-</button>
            <span style={{ fontSize: 32, fontWeight: 600, flex: 1, textAlign: 'center' }}>3</span>
            <button style={{ 
              width: 48, height: 48, borderRadius: 24, 
              border: `1px solid ${colors.outline}`, 
              backgroundColor: 'white',
              fontSize: 24,
              cursor: 'pointer'
            }}>+</button>
          </div>
        </Card>

        {/* Entrance Animation */}
        <Card style={{ padding: 16, marginBottom: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <label style={{ fontSize: 14, fontWeight: 500 }}>Entrance Animation</label>
            <Badge type="success">Required</Badge>
          </div>
          <Button variant="tonal" onClick={() => onNavigate('animationPicker')} style={{ width: '100%', justifyContent: 'space-between' }}>
            <span>➡️ Fly In Left</span>
            <span>Change →</span>
          </Button>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 12 }}>
            <span style={{ fontSize: 12 }}>Duration:</span>
            <input type="range" min="0.1" max="2" step="0.1" defaultValue="0.5" style={{ flex: 1 }} />
            <span style={{ fontSize: 12, fontWeight: 600 }}>0.5s</span>
          </div>
        </Card>

        {/* Active Animation */}
        <Card style={{ padding: 16, marginBottom: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <label style={{ fontSize: 14, fontWeight: 500 }}>Active Animation</label>
            <Badge type="info">Recommended: flutter</Badge>
          </div>
          <Button variant="tonal" onClick={() => onNavigate('animationPicker')} style={{ width: '100%', justifyContent: 'space-between' }}>
            <span>🦋 Flutter</span>
            <span>Change →</span>
          </Button>
          <p style={{ fontSize: 11, color: colors.outline, marginTop: 8 }}>
            Loops while object is on screen
          </p>
        </Card>

        {/* Exit Animation */}
        <Card style={{ padding: 16, marginBottom: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <label style={{ fontSize: 14, fontWeight: 500 }}>Exit Animation</label>
            <Badge type="success">Required</Badge>
          </div>
          <Button variant="tonal" onClick={() => onNavigate('animationPicker')} style={{ width: '100%', justifyContent: 'space-between' }}>
            <span>⬅️ Fly Out Right</span>
            <span>Change →</span>
          </Button>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 12 }}>
            <span style={{ fontSize: 12 }}>Duration:</span>
            <input type="range" min="0.1" max="2" step="0.1" defaultValue="0.5" style={{ flex: 1 }} />
            <span style={{ fontSize: 12, fontWeight: 600 }}>0.5s</span>
          </div>
        </Card>

        {/* Sound Effect */}
        <Card style={{ padding: 16 }}>
          <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Sound Effect</label>
          <Select 
            options={[
              { value: 'flutter', label: '🦋 Flutter sound' },
              { value: 'pop', label: '💥 Pop' },
              { value: 'none', label: '🔇 No sound' },
            ]}
          />
        </Card>
      </div>

      <div style={{ padding: 20, backgroundColor: colors.surface, borderTop: `1px solid ${colors.outlineVariant}` }}>
        <div style={{ display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Cancel
          </Button>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Save Object
          </Button>
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 6: ANIMATION PICKER ====================
const AnimationPickerScreen = ({ onNavigate }) => {
  const [category, setCategory] = useState('entrance');
  
  const effects = {
    entrance: [
      { id: 'appear', icon: '👁️', label: 'Appear', desc: 'Instant' },
      { id: 'fade', icon: '🌫️', label: 'Fade In', desc: 'Smooth opacity' },
      { id: 'flyInLeft', icon: '⬅️', label: 'Fly In Left' },
      { id: 'flyInRight', icon: '➡️', label: 'Fly In Right' },
      { id: 'flyInTop', icon: '⬆️', label: 'Fly In Top' },
      { id: 'flyInBottom', icon: '⬇️', label: 'Fly In Bottom' },
      { id: 'bounce', icon: '🏀', label: 'Bounce', desc: 'Fun & playful' },
      { id: 'zoom', icon: '🔍', label: 'Zoom In' },
      { id: 'swivel', icon: '🔄', label: 'Swivel' },
      { id: 'pinwheel', icon: '🎡', label: 'Pinwheel' },
      { id: 'floatIn', icon: '🎈', label: 'Float In' },
      { id: 'growAndTurn', icon: '🌀', label: 'Grow & Turn' },
    ],
    exit: [
      { id: 'disappear', icon: '💨', label: 'Disappear' },
      { id: 'fadeOut', icon: '🌫️', label: 'Fade Out' },
      { id: 'flyOutLeft', icon: '⬅️', label: 'Fly Out Left' },
      { id: 'flyOutRight', icon: '➡️', label: 'Fly Out Right' },
      { id: 'flyOutTop', icon: '⬆️', label: 'Fly Out Top' },
      { id: 'flyOutBottom', icon: '⬇️', label: 'Fly Out Bottom' },
      { id: 'dropOut', icon: '⬇️', label: 'Drop Out', desc: 'Gravity fall' },
      { id: 'poof', icon: '💥', label: 'Poof', desc: 'Magic disappear' },
      { id: 'spinOut', icon: '🌀', label: 'Spin Out' },
      { id: 'scaleOut', icon: '🔍', label: 'Scale Out' },
    ],
    active: [
      { id: 'flutter', icon: '🦋', label: 'Flutter', desc: 'For butterflies', recommended: true },
      { id: 'hop', icon: '🐸', label: 'Hop', desc: 'For frogs' },
      { id: 'walkSlow', icon: '🐢', label: 'Walk Slow', desc: 'For turtles' },
      { id: 'swingDown', icon: '🐵', label: 'Swing Down', desc: 'For monkeys' },
      { id: 'bobbing', icon: '🫧', label: 'Bobbing', desc: 'Gentle float' },
      { id: 'wiggle', icon: '〰️', label: 'Wiggle' },
      { id: 'pulse', icon: '💓', label: 'Pulse', desc: 'Attention grab' },
      { id: 'sway', icon: '🍃', label: 'Sway', desc: 'Like breeze' },
      { id: 'spin', icon: '🔄', label: 'Spin' },
      { id: 'jump', icon: '⬆️', label: 'Jump' },
    ],
  };

  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Choose Animation" onBack={() => onNavigate('objectEditor')} />

      {/* Category Tabs */}
      <Tabs 
        tabs={[
          { id: 'entrance', label: '➡️ Entrance', icon: '➡️' },
          { id: 'exit', label: '⬅️ Exit', icon: '⬅️' },
          { id: 'active', label: '🔄 Active', icon: '🔄' },
        ]}
        activeTab={category}
        onTabChange={setCategory}
      />

      {/* Effects Grid */}
      <div style={{ flex: 1, overflow: 'auto', padding: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
          {effects[category].map(effect => (
            <Card
              key={effect.id}
              onClick={() => onNavigate('objectEditor')}
              selected={effect.recommended}
              style={{ padding: 14, textAlign: 'center', position: 'relative' }}
            >
              {effect.recommended && (
                <div style={{
                  position: 'absolute',
                  top: 4,
                  right: 4,
                  backgroundColor: colors.success,
                  color: 'white',
                  fontSize: 8,
                  padding: '2px 6px',
                  borderRadius: 8
                }}>
                  REC
                </div>
              )}
              <div style={{ fontSize: 28, marginBottom: 6 }}>{effect.icon}</div>
              <div style={{ fontSize: 12, fontWeight: 500 }}>{effect.label}</div>
              {effect.desc && (
                <div style={{ fontSize: 10, color: colors.outline, marginTop: 2 }}>{effect.desc}</div>
              )}
            </Card>
          ))}
        </div>
      </div>

      {/* Preview Area */}
      <div style={{ 
        backgroundColor: colors.surfaceContainer,
        padding: 16,
        borderTop: `1px solid ${colors.outlineVariant}`
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <div style={{
            width: 72,
            height: 72,
            borderRadius: 12,
            backgroundColor: 'white',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 40
          }}>
            🦋
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 600 }}>Preview: Fade In</div>
            <div style={{ fontSize: 12, color: colors.outline }}>Tap Play to preview</div>
          </div>
          <Button variant="filled" icon="▶️">
            Play
          </Button>
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 7: QUESTION EDITOR ====================
const QuestionEditorScreen = ({ onNavigate }) => {
  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Edit Question" onBack={() => onNavigate('main')} />

      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 12px', fontSize: 14 }}>Question Type</h4>
          <div style={{ display: 'flex', gap: 8 }}>
            {[
              { id: 'count', label: '🔢 Count objects', selected: true },
              { id: 'identify', label: '🎯 Identify' },
              { id: 'match', label: '🔗 Match' },
            ].map(type => (
              <Chip key={type.id} label={type.label} selected={type.selected} onClick={() => {}} />
            ))}
          </div>
        </Card>

        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 12px', fontSize: 14 }}>Answer Options</h4>
          
          {[
            { value: '2', correct: false },
            { value: '3', correct: true },
            { value: '4', correct: false },
          ].map((opt, idx) => (
            <div key={idx} style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: 12,
              padding: 12,
              marginBottom: 8,
              borderRadius: 12,
              backgroundColor: opt.correct ? colors.successLight : colors.surfaceContainer,
              border: opt.correct ? `2px solid ${colors.success}` : 'none'
            }}>
              <input 
                type="radio" 
                name="correct" 
                checked={opt.correct}
                onChange={() => {}}
                style={{ width: 20, height: 20 }}
              />
              <input 
                type="text" 
                value={opt.value}
                onChange={() => {}}
                style={{
                  flex: 1,
                  padding: '8px 12px',
                  borderRadius: 8,
                  border: `1px solid ${colors.outline}`,
                  fontSize: 16,
                  fontWeight: 600
                }}
              />
              <button style={{ 
                padding: 8, 
                borderRadius: 8, 
                border: 'none', 
                backgroundColor: colors.errorLight,
                cursor: 'pointer'
              }}>🗑️</button>
            </div>
          ))}
          
          <Button variant="outlined" icon="➕" style={{ width: '100%', marginTop: 8 }}>
            Add Option
          </Button>
        </Card>

        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 12px', fontSize: 14 }}>Feedback</h4>
          
          <div style={{ marginBottom: 16 }}>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
              <span style={{ fontSize: 18 }}>✓</span>
              <span style={{ fontSize: 13, fontWeight: 500, color: colors.success }}>Correct Answer</span>
            </label>
            <Select 
              options={[
                { value: 'celebration', label: '🎉 Go to Celebration scene' },
                { value: 'next', label: '➡️ Go to next scene' },
                { value: 'custom', label: '📝 Custom scene' },
              ]}
            />
          </div>
          
          <div>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
              <span style={{ fontSize: 18 }}>✗</span>
              <span style={{ fontSize: 13, fontWeight: 500, color: colors.error }}>Wrong Answer</span>
            </label>
            <Select 
              options={[
                { value: 'retry', label: '🔄 Try again (same question)' },
                { value: 'hint', label: '💡 Show hint' },
                { value: 'encouragement', label: '😊 Encouragement scene' },
              ]}
            />
          </div>
        </Card>

        <Card style={{ padding: 16 }}>
          <h4 style={{ margin: '0 0 12px', fontSize: 14 }}>Settings</h4>
          
          <label style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12, cursor: 'pointer' }}>
            <input type="checkbox" defaultChecked />
            <span style={{ fontSize: 14 }}>Show previous objects (for counting)</span>
          </label>
          
          <label style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12, cursor: 'pointer' }}>
            <input type="checkbox" />
            <span style={{ fontSize: 14 }}>Shuffle answer order</span>
          </label>
          
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ fontSize: 13 }}>Wait for answer:</span>
            <input type="number" defaultValue="30" style={{ width: 60, padding: 8, borderRadius: 8, border: `1px solid ${colors.outline}` }} />
            <span style={{ fontSize: 13 }}>seconds</span>
          </div>
        </Card>
      </div>

      <div style={{ padding: 20, backgroundColor: colors.surface, borderTop: `1px solid ${colors.outlineVariant}` }}>
        <div style={{ display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Cancel
          </Button>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Save Question
          </Button>
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 8: LOCALIZATION EDITOR ====================
const LocalizationScreen = ({ onNavigate }) => {
  const translations = [
    { code: 'en', flag: '🇬🇧', name: 'English', text: 'Let\'s count butterflies!', status: 'original', duration: '2.1s' },
    { code: 'ru', flag: '🇷🇺', name: 'Russian', text: 'Давай посчитаем бабочек!', status: 'auto', duration: '2.8s' },
    { code: 'fr', flag: '🇫🇷', name: 'French', text: 'Comptons les papillons!', status: 'edited', duration: '2.3s' },
    { code: 'de', flag: '🇩🇪', name: 'German', text: 'Lass uns Schmetterlinge zählen!', status: 'auto', duration: '3.1s' },
    { code: 'it', flag: '🇮🇹', name: 'Italian', text: 'Contiamo le farfalle!', status: 'auto', duration: '2.4s' },
    { code: 'my', flag: '🇲🇲', name: 'Myanmar', text: 'လိပ်ပြာတွေ ရေတွက်ကြမယ်!', status: 'auto', duration: '3.5s' },
    { code: 'am', flag: '🇪🇹', name: 'Amharic', text: '', status: 'missing', duration: '—' },
  ];

  const statusConfig = {
    original: { color: colors.primary, label: 'Original' },
    auto: { color: colors.warning, label: 'Auto' },
    edited: { color: colors.success, label: 'Edited' },
    missing: { color: colors.error, label: 'Missing' },
  };

  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar 
        title="All Translations" 
        subtitle="Scene 3"
        onBack={() => onNavigate('main')}
        actions={
          <Button variant="text" style={{ color: 'white' }} icon="🤖">
            Re-translate
          </Button>
        }
      />

      {/* Legend */}
      <div style={{ 
        display: 'flex', 
        gap: 12, 
        padding: '12px 20px',
        backgroundColor: colors.surface,
        borderBottom: `1px solid ${colors.outlineVariant}`,
        overflowX: 'auto'
      }}>
        {Object.entries(statusConfig).map(([key, config]) => (
          <div key={key} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 11 }}>
            <div style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: config.color }} />
            {config.label}
          </div>
        ))}
      </div>

      {/* Context */}
      <div style={{ padding: '12px 20px', backgroundColor: colors.infoLight }}>
        <div style={{ fontSize: 12, color: colors.info }}>
          <strong>Context:</strong> Playful invitation to count butterflies. Keep it short and enthusiastic!
        </div>
      </div>

      {/* Translations List */}
      <div style={{ flex: 1, overflow: 'auto', padding: '16px 20px' }}>
        {translations.map(trans => {
          const config = statusConfig[trans.status];
          const isLong = trans.duration !== '—' && parseFloat(trans.duration) > 2.5;
          
          return (
            <Card
              key={trans.code}
              style={{ 
                padding: 16, 
                marginBottom: 12,
                borderLeft: `4px solid ${config.color}`
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', marginBottom: 10 }}>
                <span style={{ fontSize: 20, marginRight: 8 }}>{trans.flag}</span>
                <span style={{ fontWeight: 600, fontSize: 14 }}>{trans.name}</span>
                <Badge type={trans.status === 'missing' ? 'error' : trans.status === 'auto' ? 'warning' : 'success'} style={{ marginLeft: 8 }}>
                  {config.label}
                </Badge>
                <span style={{ marginLeft: 'auto', fontSize: 12, color: colors.outline }}>
                  🔊 {trans.duration}
                </span>
              </div>
              
              <div style={{ display: 'flex', gap: 8 }}>
                <input
                  type="text"
                  value={trans.text}
                  placeholder={trans.status === 'missing' ? 'Translation missing...' : ''}
                  disabled={trans.status === 'original'}
                  style={{
                    flex: 1,
                    padding: 12,
                    borderRadius: 8,
                    border: `1px solid ${colors.outline}`,
                    fontSize: 14,
                    backgroundColor: trans.status === 'original' ? colors.surfaceContainer : 'white'
                  }}
                />
                <Button variant="tonal" style={{ padding: 12 }}>🔊</Button>
                {trans.status !== 'original' && (
                  <Button variant="tonal" style={{ padding: 12 }}>✏️</Button>
                )}
              </div>
              
              {isLong && (
                <div style={{ 
                  marginTop: 10, 
                  padding: '8px 12px',
                  backgroundColor: colors.warningLight,
                  borderRadius: 8,
                  fontSize: 12,
                  color: colors.warning,
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8
                }}>
                  ⚠️ This translation is {(parseFloat(trans.duration) - 2.1).toFixed(1)}s longer than English
                </div>
              )}
            </Card>
          );
        })}
      </div>

      <div style={{ padding: '12px 20px', backgroundColor: colors.surface, borderTop: `1px solid ${colors.outlineVariant}` }}>
        <Button variant="filled" onClick={() => onNavigate('main')} style={{ width: '100%' }}>
          Done
        </Button>
      </div>
    </div>
  );
};

// ==================== SCREEN 9: TTS DURATION COMPARISON ====================
const TTSDurationScreen = ({ onNavigate }) => {
  const durations = [
    { code: 'en', flag: '🇬🇧', name: 'English', duration: 2.1, baseline: true },
    { code: 'fr', flag: '🇫🇷', name: 'French', duration: 2.3, diff: '+0.2s' },
    { code: 'it', flag: '🇮🇹', name: 'Italian', duration: 2.4, diff: '+0.3s' },
    { code: 'ru', flag: '🇷🇺', name: 'Russian', duration: 2.8, diff: '+0.7s' },
    { code: 'de', flag: '🇩🇪', name: 'German', duration: 3.1, diff: '+1.0s', warning: true },
    { code: 'my', flag: '🇲🇲', name: 'Myanmar', duration: 3.5, diff: '+1.4s', warning: true },
  ];

  const maxDuration = 4;

  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="TTS Duration Check" onBack={() => onNavigate('main')} />

      <div style={{ padding: 20, backgroundColor: colors.surface, borderBottom: `1px solid ${colors.outlineVariant}` }}>
        <div style={{ fontSize: 14, marginBottom: 8 }}>
          <strong>Text:</strong> "Let's count butterflies!"
        </div>
        <div style={{ fontSize: 12, color: colors.outline }}>
          Scene duration: 5s • Recommended max TTS: 3.5s
        </div>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        {durations.map(lang => (
          <div key={lang.code} style={{ marginBottom: 16 }}>
            <div style={{ display: 'flex', alignItems: 'center', marginBottom: 6 }}>
              <span style={{ fontSize: 18, marginRight: 8 }}>{lang.flag}</span>
              <span style={{ fontSize: 14, fontWeight: 500, flex: 1 }}>{lang.name}</span>
              <span style={{ 
                fontSize: 14, 
                fontWeight: 600,
                color: lang.warning ? colors.warning : colors.onSurface
              }}>
                {lang.duration}s
              </span>
              {lang.diff && (
                <span style={{ 
                  fontSize: 12, 
                  color: lang.warning ? colors.warning : colors.outline,
                  marginLeft: 8
                }}>
                  {lang.diff}
                </span>
              )}
            </div>
            <div style={{ 
              height: 24, 
              backgroundColor: colors.surfaceVariant, 
              borderRadius: 12,
              overflow: 'hidden'
            }}>
              <div style={{
                width: `${(lang.duration / maxDuration) * 100}%`,
                height: '100%',
                backgroundColor: lang.warning ? colors.warning : colors.primary,
                borderRadius: 12,
                transition: 'width 0.3s'
              }} />
            </div>
          </div>
        ))}

        {/* Threshold line */}
        <div style={{ 
          marginTop: 24,
          padding: 16,
          backgroundColor: colors.warningLight,
          borderRadius: 12
        }}>
          <h4 style={{ margin: '0 0 8px', fontSize: 14, color: colors.warning }}>⚠️ Duration Warnings</h4>
          <p style={{ margin: 0, fontSize: 13, color: colors.onSurface }}>
            German and Myanmar translations exceed recommended duration. Consider:
          </p>
          <ul style={{ margin: '8px 0 0', paddingLeft: 20, fontSize: 13 }}>
            <li>Shortening the text</li>
            <li>Adjusting scene duration</li>
            <li>Using faster TTS speed</li>
          </ul>
        </div>
      </div>

      <div style={{ padding: 20, backgroundColor: colors.surface, borderTop: `1px solid ${colors.outlineVariant}` }}>
        <div style={{ display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('localization')} style={{ flex: 1 }} icon="✏️">
            Edit Translations
          </Button>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Done
          </Button>
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 10: POSITIONING ====================
const PositioningScreen = ({ onNavigate }) => {
  return (
    <div style={{ height: '100vh', backgroundColor: '#1a1a1a', display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Position Objects" onBack={() => onNavigate('main')} />

      {/* Canvas */}
      <div style={{ 
        flex: 1, 
        position: 'relative',
        backgroundColor: '#2d5a27',
        backgroundImage: 'linear-gradient(to bottom, #3d7a37 0%, #2d5a27 100%)',
      }}>
        {/* Grid overlay */}
        <div style={{
          position: 'absolute',
          inset: 0,
          backgroundImage: 'linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)',
          backgroundSize: '50px 50px',
          pointerEvents: 'none'
        }} />

        {/* Character */}
        <div style={{
          position: 'absolute',
          bottom: '20%',
          left: '25%',
          fontSize: 80,
          cursor: 'move',
          filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.3))'
        }}>
          🐱
        </div>
        
        {/* Objects */}
        <div style={{
          position: 'absolute',
          top: '20%',
          right: '30%',
          fontSize: 48,
          cursor: 'move'
        }}>
          🦋
        </div>
        <div style={{
          position: 'absolute',
          top: '30%',
          right: '20%',
          fontSize: 48,
          cursor: 'move'
        }}>
          🦋
        </div>
        <div style={{
          position: 'absolute',
          top: '15%',
          right: '40%',
          fontSize: 48,
          cursor: 'move'
        }}>
          🦋
        </div>

        {/* Selection indicator */}
        <div style={{
          position: 'absolute',
          top: '20%',
          right: '30%',
          width: 60,
          height: 60,
          border: '2px dashed white',
          borderRadius: 8,
          pointerEvents: 'none'
        }} />

        {/* Coordinates display */}
        <div style={{
          position: 'absolute',
          bottom: 16,
          left: 16,
          backgroundColor: 'rgba(0,0,0,0.7)',
          padding: '8px 12px',
          borderRadius: 8,
          color: 'white',
          fontSize: 12,
          fontFamily: 'monospace'
        }}>
          Selected: Butterfly 1<br />
          X: 280 Y: 120
        </div>
      </div>

      {/* Controls */}
      <div style={{ backgroundColor: '#2a2a2a', padding: 16 }}>
        <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
          <Button variant="tonal" style={{ flex: 1, padding: '10px 8px', fontSize: 12 }}>
            📐 Grid: On
          </Button>
          <Button variant="tonal" style={{ flex: 1, padding: '10px 8px', fontSize: 12 }}>
            🧲 Snap: On
          </Button>
          <Button variant="tonal" style={{ flex: 1, padding: '10px 8px', fontSize: 12 }}>
            📏 Guides
          </Button>
        </div>
        
        <div style={{ marginBottom: 12 }}>
          <div style={{ fontSize: 12, color: '#888', marginBottom: 8 }}>Quick positions:</div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {['Top Left', 'Top Center', 'Top Right', 'Center', 'Bottom Left', 'Bottom Center', 'Bottom Right'].map(pos => (
              <button key={pos} style={{
                padding: '6px 10px',
                borderRadius: 8,
                border: '1px solid #444',
                backgroundColor: '#333',
                color: 'white',
                fontSize: 11,
                cursor: 'pointer'
              }}>
                {pos}
              </button>
            ))}
          </div>
        </div>

        <div style={{ display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('main')} style={{ flex: 1, borderColor: '#555', color: 'white' }}>
            Cancel
          </Button>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Save Positions
          </Button>
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 11: LIVE PREVIEW ====================
const LivePreviewScreen = ({ onNavigate }) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(2.5);
  const [selectedLang, setSelectedLang] = useState('en');
  const totalTime = 5;

  const tracks = [
    { label: 'Orson', color: colors.secondary, segments: [{ start: 0, end: 100 }] },
    { label: '🦋 x3', color: colors.tertiary, segments: [{ start: 20, end: 90 }] },
    { label: 'Dialogue', color: colors.primary, segments: [{ start: 10, end: 60 }] },
    { label: 'Audio', color: colors.info, segments: [{ start: 0, end: 100 }] },
  ];

  return (
    <div style={{ height: '100vh', backgroundColor: '#1a1a1a', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <div style={{
        backgroundColor: colors.primaryDark,
        padding: '12px 20px',
        display: 'flex',
        alignItems: 'center',
        gap: 16
      }}>
        <button onClick={() => onNavigate('main')} style={{
          background: 'none', border: 'none', color: 'white', fontSize: 24, cursor: 'pointer'
        }}>✕</button>
        <span style={{ color: 'white', fontSize: 16, fontWeight: 600, flex: 1 }}>Scene 3 Preview</span>
        
        {/* Language selector */}
        <div style={{ display: 'flex', gap: 4 }}>
          {['en', 'fr', 'de', 'ru'].map(lang => (
            <button
              key={lang}
              onClick={() => setSelectedLang(lang)}
              style={{
                width: 36,
                height: 36,
                borderRadius: 18,
                border: selectedLang === lang ? '2px solid white' : '1px solid rgba(255,255,255,0.3)',
                backgroundColor: selectedLang === lang ? 'rgba(255,255,255,0.2)' : 'transparent',
                cursor: 'pointer',
                fontSize: 16
              }}
            >
              {lang === 'en' ? '🇬🇧' : lang === 'fr' ? '🇫🇷' : lang === 'de' ? '🇩🇪' : '🇷🇺'}
            </button>
          ))}
        </div>
      </div>

      {/* Preview Area */}
      <div style={{ 
        flex: 1, 
        position: 'relative',
        backgroundColor: '#2d5a27',
        backgroundImage: 'linear-gradient(to bottom, #3d7a37 0%, #2d5a27 100%)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}>
        {/* Character */}
        <div style={{
          position: 'absolute',
          bottom: '15%',
          left: '25%',
          fontSize: 100,
          filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.3))'
        }}>
          🐱
        </div>
        
        {/* Objects */}
        <div style={{
          position: 'absolute',
          top: '20%',
          right: '15%',
          display: 'flex',
          gap: 20,
          fontSize: 48
        }}>
          🦋 🦋 🦋
        </div>
        
        {/* Dialogue Bubble */}
        <div style={{
          position: 'absolute',
          bottom: '40%',
          left: '40%',
          backgroundColor: 'white',
          borderRadius: 20,
          padding: '16px 24px',
          maxWidth: 280,
          boxShadow: '0 4px 12px rgba(0,0,0,0.2)'
        }}>
          <p style={{ margin: 0, fontSize: 18, color: colors.secondary }}>
            {selectedLang === 'en' ? "Let's count butterflies!" :
             selectedLang === 'fr' ? "Comptons les papillons!" :
             selectedLang === 'de' ? "Lass uns Schmetterlinge zählen!" :
             "Давай посчитаем бабочек!"}
          </p>
        </div>

        {/* Time indicator */}
        <div style={{
          position: 'absolute',
          top: 16,
          left: 16,
          backgroundColor: 'rgba(0,0,0,0.6)',
          borderRadius: 8,
          padding: '8px 12px',
          color: 'white',
          fontSize: 14,
          fontFamily: 'monospace'
        }}>
          {currentTime.toFixed(1)}s / {totalTime}s
        </div>
      </div>

      {/* Timeline Controls */}
      <div style={{ backgroundColor: '#2a2a2a', padding: 16 }}>
        {/* Mini tracks */}
        <div style={{ marginBottom: 12 }}>
          {tracks.map((track, idx) => (
            <div key={idx} style={{ display: 'flex', alignItems: 'center', marginBottom: 4 }}>
              <span style={{ width: 60, fontSize: 10, color: '#888', textAlign: 'right', paddingRight: 8 }}>
                {track.label}
              </span>
              <div style={{ flex: 1, height: 16, backgroundColor: '#333', borderRadius: 2, position: 'relative' }}>
                {track.segments.map((seg, i) => (
                  <div
                    key={i}
                    style={{
                      position: 'absolute',
                      left: `${seg.start}%`,
                      width: `${seg.end - seg.start}%`,
                      height: '100%',
                      backgroundColor: track.color,
                      opacity: 0.8,
                      borderRadius: 2
                    }}
                  />
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Scrubber */}
        <div style={{ marginBottom: 16 }}>
          <input
            type="range"
            min="0"
            max={totalTime}
            step="0.1"
            value={currentTime}
            onChange={(e) => setCurrentTime(parseFloat(e.target.value))}
            style={{ width: '100%' }}
          />
        </div>

        {/* Playback controls */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: 16 }}>
          <button style={{
            width: 48, height: 48, borderRadius: 24,
            border: 'none', backgroundColor: '#444', color: 'white', fontSize: 18, cursor: 'pointer'
          }}>⏮️</button>
          <button 
            onClick={() => setIsPlaying(!isPlaying)}
            style={{
              width: 64, height: 64, borderRadius: 32,
              border: 'none', backgroundColor: colors.primary, color: 'white', fontSize: 24, cursor: 'pointer'
            }}
          >
            {isPlaying ? '⏸️' : '▶️'}
          </button>
          <button style={{
            width: 48, height: 48, borderRadius: 24,
            border: 'none', backgroundColor: '#444', color: 'white', fontSize: 18, cursor: 'pointer'
          }}>⏭️</button>
        </div>
      </div>
    </div>
  );
};

// ==================== SCREEN 12: VALIDATION ====================
const ValidationScreen = ({ onNavigate }) => {
  const issues = [
    { type: 'error', scene: 6, message: 'Missing dialogue text', field: 'dialogue' },
    { type: 'warning', scene: 4, message: 'No exit animation for character', field: 'animation' },
    { type: 'warning', scene: 3, message: 'German TTS exceeds scene duration', field: 'localization' },
    { type: 'info', scene: 2, message: 'Consider adding objects to pause scene', field: 'objects' },
  ];

  const typeConfig = {
    error: { color: colors.error, icon: '❌', label: 'Error' },
    warning: { color: colors.warning, icon: '⚠️', label: 'Warning' },
    info: { color: colors.info, icon: 'ℹ️', label: 'Info' },
  };

  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Validation" subtitle="4 issues found" onBack={() => onNavigate('main')} />

      {/* Summary */}
      <div style={{ 
        display: 'flex', 
        padding: '16px 20px',
        backgroundColor: colors.surface,
        borderBottom: `1px solid ${colors.outlineVariant}`,
        gap: 16
      }}>
        {[
          { type: 'error', count: 1 },
          { type: 'warning', count: 2 },
          { type: 'info', count: 1 },
        ].map(item => (
          <div key={item.type} style={{ 
            flex: 1, 
            textAlign: 'center',
            padding: 12,
            borderRadius: 12,
            backgroundColor: typeConfig[item.type].color + '20'
          }}>
            <div style={{ fontSize: 24, marginBottom: 4 }}>{typeConfig[item.type].icon}</div>
            <div style={{ fontSize: 20, fontWeight: 700, color: typeConfig[item.type].color }}>{item.count}</div>
            <div style={{ fontSize: 11, color: colors.outline }}>{typeConfig[item.type].label}s</div>
          </div>
        ))}
      </div>

      {/* Issues List */}
      <div style={{ flex: 1, overflow: 'auto', padding: '16px 20px' }}>
        {issues.map((issue, idx) => {
          const config = typeConfig[issue.type];
          return (
            <Card
              key={idx}
              onClick={() => onNavigate('main')}
              style={{ 
                padding: 16, 
                marginBottom: 12,
                borderLeft: `4px solid ${config.color}`
              }}
            >
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <span style={{ fontSize: 20 }}>{config.icon}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                    <Badge type={issue.type}>{config.label}</Badge>
                    <span style={{ fontSize: 12, color: colors.outline }}>Scene {issue.scene}</span>
                  </div>
                  <p style={{ margin: 0, fontSize: 14 }}>{issue.message}</p>
                </div>
                <span style={{ color: colors.outline }}>→</span>
              </div>
            </Card>
          );
        })}
      </div>

      <div style={{ padding: '12px 20px', backgroundColor: colors.surface, borderTop: `1px solid ${colors.outlineVariant}` }}>
        <Button variant="filled" onClick={() => onNavigate('main')} style={{ width: '100%' }}>
          Fix All Issues
        </Button>
      </div>
    </div>
  );
};

// ==================== SCREEN 13: EXPORT ====================
const ExportScreen = ({ onNavigate }) => {
  return (
    <div style={{ 
      height: '100vh', 
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 20
    }}>
      <Card style={{ width: '100%', maxWidth: 400 }}>
        <div style={{ padding: 20, borderBottom: `1px solid ${colors.outlineVariant}` }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <h2 style={{ margin: 0, fontSize: 20 }}>📤 Export Lesson</h2>
            <button onClick={() => onNavigate('main')} style={{
              background: 'none', border: 'none', fontSize: 24, cursor: 'pointer', color: colors.outline
            }}>✕</button>
          </div>
        </div>

        <div style={{ padding: 20 }}>
          <div style={{ marginBottom: 16 }}>
            <div style={{ fontSize: 14, fontWeight: 500 }}>Counting 1-5</div>
            <div style={{ fontSize: 13, color: colors.outline }}>12 scenes • 7 languages</div>
          </div>

          <div style={{ marginBottom: 20 }}>
            <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Format</label>
            <div style={{ display: 'flex', gap: 8 }}>
              {['JSON', 'YAML', 'ZIP'].map(fmt => (
                <Card
                  key={fmt}
                  selected={fmt === 'JSON'}
                  onClick={() => {}}
                  style={{ flex: 1, padding: 14, textAlign: 'center' }}
                >
                  {fmt}
                </Card>
              ))}
            </div>
          </div>

          <div style={{ marginBottom: 20 }}>
            <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>Include</label>
            {[
              { id: 'translations', label: 'All translations', checked: true },
              { id: 'audio', label: 'Audio files', checked: false },
              { id: 'backgrounds', label: 'Background images', checked: false },
            ].map(opt => (
              <label key={opt.id} style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10, cursor: 'pointer' }}>
                <input type="checkbox" defaultChecked={opt.checked} />
                <span style={{ fontSize: 14 }}>{opt.label}</span>
              </label>
            ))}
          </div>
        </div>

        <div style={{ padding: '16px 20px', backgroundColor: colors.surfaceContainer, display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Cancel
          </Button>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ flex: 1 }} icon="📤">
            Export
          </Button>
        </div>
      </Card>
    </div>
  );
};

// ==================== SCREEN 14: IMPORT ====================
const ImportScreen = ({ onNavigate }) => {
  return (
    <div style={{ 
      height: '100vh', 
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 20
    }}>
      <Card style={{ width: '100%', maxWidth: 400 }}>
        <div style={{ padding: 20, borderBottom: `1px solid ${colors.outlineVariant}` }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <h2 style={{ margin: 0, fontSize: 20 }}>📥 Import Lesson</h2>
            <button onClick={() => onNavigate('main')} style={{
              background: 'none', border: 'none', fontSize: 24, cursor: 'pointer', color: colors.outline
            }}>✕</button>
          </div>
        </div>

        <div style={{ padding: 20 }}>
          {/* Drop zone */}
          <div style={{
            border: `2px dashed ${colors.outline}`,
            borderRadius: 16,
            padding: '40px 20px',
            textAlign: 'center',
            marginBottom: 20
          }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>📁</div>
            <div style={{ fontSize: 14, fontWeight: 500, marginBottom: 4 }}>Drop file here</div>
            <div style={{ fontSize: 13, color: colors.outline, marginBottom: 12 }}>or</div>
            <Button variant="outlined">Browse Files</Button>
            <div style={{ fontSize: 11, color: colors.outline, marginTop: 12 }}>
              Supports: JSON, YAML, ZIP
            </div>
          </div>

          <div style={{ marginBottom: 16 }}>
            <label style={{ display: 'block', fontSize: 14, fontWeight: 500, marginBottom: 12 }}>
              If lesson exists:
            </label>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {[
                { id: 'new', label: 'Create as new lesson', checked: true },
                { id: 'replace', label: 'Replace existing' },
                { id: 'merge', label: 'Merge scenes' },
              ].map(opt => (
                <label key={opt.id} style={{ display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}>
                  <input type="radio" name="conflict" defaultChecked={opt.checked} />
                  <span style={{ fontSize: 14 }}>{opt.label}</span>
                </label>
              ))}
            </div>
          </div>
        </div>

        <div style={{ padding: '16px 20px', backgroundColor: colors.surfaceContainer, display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('main')} style={{ flex: 1 }}>
            Cancel
          </Button>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ flex: 1 }} icon="📥" disabled>
            Import
          </Button>
        </div>
      </Card>
    </div>
  );
};

// ==================== SCREEN 15: KEYBOARD SHORTCUTS ====================
const ShortcutsScreen = ({ onNavigate }) => {
  const shortcuts = [
    { category: 'General', items: [
      { keys: '⌘ S', action: 'Save lesson' },
      { keys: '⌘ Z', action: 'Undo' },
      { keys: '⌘ ⇧ Z', action: 'Redo' },
      { keys: '⌘ E', action: 'Export' },
      { keys: '⌘ I', action: 'Import' },
    ]},
    { category: 'Scenes', items: [
      { keys: '⌘ N', action: 'New scene' },
      { keys: '⌘ D', action: 'Duplicate scene' },
      { keys: '⌘ ⌫', action: 'Delete scene' },
      { keys: '↑ / ↓', action: 'Navigate scenes' },
    ]},
    { category: 'Preview', items: [
      { keys: '⌘ P', action: 'Preview scene' },
      { keys: 'Space', action: 'Play / Pause' },
      { keys: '← / →', action: 'Scrub timeline' },
    ]},
  ];

  return (
    <div style={{ 
      height: '100vh', 
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 20
    }}>
      <Card style={{ width: '100%', maxWidth: 400 }}>
        <div style={{ padding: 20, borderBottom: `1px solid ${colors.outlineVariant}` }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <h2 style={{ margin: 0, fontSize: 20 }}>⌨️ Keyboard Shortcuts</h2>
            <button onClick={() => onNavigate('main')} style={{
              background: 'none', border: 'none', fontSize: 24, cursor: 'pointer', color: colors.outline
            }}>✕</button>
          </div>
        </div>

        <div style={{ padding: 20, maxHeight: 400, overflow: 'auto' }}>
          {shortcuts.map(section => (
            <div key={section.category} style={{ marginBottom: 20 }}>
              <h4 style={{ margin: '0 0 12px', fontSize: 14, color: colors.outline }}>{section.category}</h4>
              {section.items.map((item, idx) => (
                <div key={idx} style={{ 
                  display: 'flex', 
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  padding: '8px 0',
                  borderBottom: idx < section.items.length - 1 ? `1px solid ${colors.surfaceVariant}` : 'none'
                }}>
                  <span style={{ fontSize: 14 }}>{item.action}</span>
                  <kbd style={{
                    backgroundColor: colors.surfaceContainer,
                    padding: '4px 8px',
                    borderRadius: 6,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    border: `1px solid ${colors.outlineVariant}`
                  }}>
                    {item.keys}
                  </kbd>
                </div>
              ))}
            </div>
          ))}
        </div>

        <div style={{ padding: '16px 20px', backgroundColor: colors.surfaceContainer }}>
          <Button variant="filled" onClick={() => onNavigate('main')} style={{ width: '100%' }}>
            Done
          </Button>
        </div>
      </Card>
    </div>
  );
};

// ==================== SCREEN 16: UNDO/REDO HISTORY ====================
const HistoryScreen = ({ onNavigate }) => {
  const history = [
    { id: 1, action: 'Changed dialogue text', scene: 3, time: 'Just now', current: true },
    { id: 2, action: 'Added butterfly object', scene: 3, time: '2 min ago' },
    { id: 3, action: 'Changed character emotion', scene: 3, time: '5 min ago' },
    { id: 4, action: 'Created new scene', scene: 3, time: '8 min ago' },
    { id: 5, action: 'Deleted scene', scene: 2, time: '10 min ago' },
    { id: 6, action: 'Changed transition type', scene: 2, time: '12 min ago' },
  ];

  return (
    <div style={{ 
      height: '100vh', 
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 20
    }}>
      <Card style={{ width: '100%', maxWidth: 400 }}>
        <div style={{ padding: 20, borderBottom: `1px solid ${colors.outlineVariant}` }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <h2 style={{ margin: 0, fontSize: 20 }}>↩️ History</h2>
            <button onClick={() => onNavigate('main')} style={{
              background: 'none', border: 'none', fontSize: 24, cursor: 'pointer', color: colors.outline
            }}>✕</button>
          </div>
        </div>

        <div style={{ maxHeight: 400, overflow: 'auto' }}>
          {history.map((item, idx) => (
            <div
              key={item.id}
              style={{
                padding: '12px 20px',
                borderBottom: `1px solid ${colors.surfaceVariant}`,
                backgroundColor: item.current ? colors.primaryLight : 'transparent',
                cursor: 'pointer'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ 
                  width: 24, 
                  height: 24, 
                  borderRadius: 12,
                  backgroundColor: item.current ? colors.primary : colors.surfaceVariant,
                  color: item.current ? 'white' : colors.outline,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: 12
                }}>
                  {idx + 1}
                </span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: item.current ? 600 : 400 }}>{item.action}</div>
                  <div style={{ fontSize: 12, color: colors.outline }}>Scene {item.scene} • {item.time}</div>
                </div>
                {item.current && <Badge type="success">Current</Badge>}
              </div>
            </div>
          ))}
        </div>

        <div style={{ padding: '16px 20px', backgroundColor: colors.surfaceContainer, display: 'flex', gap: 12 }}>
          <Button variant="outlined" onClick={() => onNavigate('main')} style={{ flex: 1 }} icon="↩️">
            Undo
          </Button>
          <Button variant="outlined" onClick={() => onNavigate('main')} style={{ flex: 1 }} icon="↪️">
            Redo
          </Button>
        </div>
      </Card>
    </div>
  );
};

// ==================== SCREEN 17: CONTEXT MENU ====================
const ContextMenuScreen = ({ onNavigate }) => {
  const actions = [
    { icon: '📋', label: 'Duplicate Scene', shortcut: '⌘D' },
    { icon: '✂️', label: 'Cut Scene', shortcut: '⌘X' },
    { icon: '📄', label: 'Copy Scene', shortcut: '⌘C' },
    { icon: '📥', label: 'Paste Before', shortcut: '⌘V' },
    { divider: true },
    { icon: '⬆️', label: 'Move Up' },
    { icon: '⬇️', label: 'Move Down' },
    { divider: true },
    { icon: '💾', label: 'Save as Template' },
    { divider: true },
    { icon: '🗑️', label: 'Delete Scene', shortcut: '⌘⌫', danger: true },
  ];

  return (
    <div style={{ 
      height: '100vh', 
      backgroundColor: 'rgba(0,0,0,0.3)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 20
    }}
    onClick={() => onNavigate('main')}
    >
      <Card style={{ width: 250 }} onClick={e => e.stopPropagation()}>
        <div style={{ padding: '8px 0' }}>
          {actions.map((action, idx) => (
            action.divider ? (
              <div key={idx} style={{ height: 1, backgroundColor: colors.surfaceVariant, margin: '8px 0' }} />
            ) : (
              <button
                key={idx}
                onClick={() => onNavigate('main')}
                style={{
                  width: '100%',
                  padding: '12px 16px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  border: 'none',
                  backgroundColor: 'transparent',
                  cursor: 'pointer',
                  textAlign: 'left',
                  color: action.danger ? colors.error : colors.onSurface
                }}
              >
                <span style={{ fontSize: 18 }}>{action.icon}</span>
                <span style={{ flex: 1, fontSize: 14 }}>{action.label}</span>
                {action.shortcut && (
                  <span style={{ fontSize: 11, color: colors.outline }}>{action.shortcut}</span>
                )}
              </button>
            )
          ))}
        </div>
      </Card>
    </div>
  );
};

// ==================== SCREEN 18: LESSON SETTINGS ====================
const LessonSettingsScreen = ({ onNavigate }) => {
  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Lesson Settings" onBack={() => onNavigate('main')} />

      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>📝 Details</h4>
          <TextField label="Title" value="Counting 1-5" />
          <TextField label="Description" value="Learn to count from 1 to 5 with Orson!" multiline rows={2} />
          <Select 
            label="Topic"
            options={[
              { value: 'counting', label: '🔢 Counting' },
              { value: 'letters', label: '🔤 Letters' },
              { value: 'colors', label: '🎨 Colors' },
            ]}
          />
          <Select 
            label="Difficulty"
            options={[
              { value: 'easy', label: '🟢 Easy (3-4 years)' },
              { value: 'medium', label: '🟡 Medium (4-5 years)' },
              { value: 'hard', label: '🔴 Hard (5-7 years)' },
            ]}
          />
        </Card>

        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>🌐 Languages</h4>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {[
              { code: 'en', flag: '🇬🇧', name: 'English', enabled: true },
              { code: 'ru', flag: '🇷🇺', name: 'Russian', enabled: true },
              { code: 'fr', flag: '🇫🇷', name: 'French', enabled: true },
              { code: 'de', flag: '🇩🇪', name: 'German', enabled: true },
              { code: 'it', flag: '🇮🇹', name: 'Italian', enabled: true },
              { code: 'my', flag: '🇲🇲', name: 'Myanmar', enabled: true },
              { code: 'am', flag: '🇪🇹', name: 'Amharic', enabled: true },
            ].map(lang => (
              <Chip
                key={lang.code}
                label={`${lang.flag} ${lang.name}`}
                selected={lang.enabled}
                onClick={() => {}}
              />
            ))}
          </div>
        </Card>

        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>⚙️ Defaults</h4>
          
          <div style={{ marginBottom: 16 }}>
            <label style={{ display: 'block', fontSize: 13, marginBottom: 8 }}>Default pause duration</label>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <input type="range" min="1" max="10" defaultValue="3" style={{ flex: 1 }} />
              <span style={{ fontWeight: 600 }}>3s</span>
            </div>
          </div>
          
          <div style={{ marginBottom: 16 }}>
            <label style={{ display: 'block', fontSize: 13, marginBottom: 8 }}>Default background</label>
            <Select 
              options={[
                { value: 'jungle_morning', label: '🌅 Jungle Morning' },
                { value: 'jungle_evening', label: '🌙 Jungle Evening' },
              ]}
            />
          </div>
          
          <label style={{ display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}>
            <input type="checkbox" defaultChecked />
            <span style={{ fontSize: 14 }}>Auto-play TTS after scene load</span>
          </label>
        </Card>

        <Card style={{ padding: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>🏷️ Tags</h4>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 12 }}>
            {['counting', 'numbers', 'math', 'basic'].map(tag => (
              <Badge key={tag} type="default">{tag} ✕</Badge>
            ))}
          </div>
          <TextField placeholder="Add new tag..." />
        </Card>
      </div>

      <div style={{ padding: 20, backgroundColor: colors.surface, borderTop: `1px solid ${colors.outlineVariant}` }}>
        <Button variant="filled" onClick={() => onNavigate('main')} style={{ width: '100%' }}>
          Save Settings
        </Button>
      </div>
    </div>
  );
};

// ==================== SCREEN 19: APP SETTINGS ====================
const AppSettingsScreen = ({ onNavigate }) => {
  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Editor Settings" onBack={() => onNavigate('lessons')} />

      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>🎨 Appearance</h4>
          
          <div style={{ marginBottom: 16 }}>
            <label style={{ display: 'block', fontSize: 13, marginBottom: 8 }}>Theme</label>
            <div style={{ display: 'flex', gap: 8 }}>
              {['Light', 'Dark', 'System'].map(theme => (
                <Chip key={theme} label={theme} selected={theme === 'Light'} onClick={() => {}} />
              ))}
            </div>
          </div>
          
          <label style={{ display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}>
            <input type="checkbox" defaultChecked />
            <span style={{ fontSize: 14 }}>Show scene thumbnails</span>
          </label>
        </Card>

        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>🔊 TTS Settings</h4>
          
          <Select 
            label="TTS Provider"
            options={[
              { value: 'azure', label: 'Azure Cognitive Services' },
              { value: 'google', label: 'Google Cloud TTS' },
              { value: 'system', label: 'System TTS' },
            ]}
          />
          
          <div style={{ marginBottom: 16 }}>
            <label style={{ display: 'block', fontSize: 13, marginBottom: 8 }}>Speech rate</label>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <span style={{ fontSize: 12 }}>Slow</span>
              <input type="range" min="0.5" max="1.5" step="0.1" defaultValue="1" style={{ flex: 1 }} />
              <span style={{ fontSize: 12 }}>Fast</span>
            </div>
          </div>
        </Card>

        <Card style={{ padding: 16, marginBottom: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>🤖 Auto-Translation</h4>
          
          <Select 
            label="Translation Provider"
            options={[
              { value: 'claude', label: 'Claude API' },
              { value: 'google', label: 'Google Translate' },
              { value: 'deepl', label: 'DeepL' },
            ]}
          />
          
          <label style={{ display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer', marginTop: 12 }}>
            <input type="checkbox" defaultChecked />
            <span style={{ fontSize: 14 }}>Auto-translate on dialogue change</span>
          </label>
        </Card>

        <Card style={{ padding: 16 }}>
          <h4 style={{ margin: '0 0 16px', fontSize: 14 }}>💾 Data</h4>
          
          <Button variant="outlined" style={{ width: '100%', marginBottom: 12 }} icon="📤">
            Export All Lessons
          </Button>
          
          <Button variant="outlined" style={{ width: '100%', marginBottom: 12 }} icon="📥">
            Import Lessons
          </Button>
          
          <Button variant="outlined" color={colors.error} style={{ width: '100%' }} icon="🗑️">
            Clear All Data
          </Button>
        </Card>
      </div>
    </div>
  );
};

// ==================== NAVIGATION MENU ====================
const NavigationMenu = ({ onNavigate }) => {
  const screens = [
    { section: 'Main Flow', items: [
      { id: 'lessons', icon: '📚', label: 'Lessons List', desc: 'Browse all lessons' },
      { id: 'newLesson', icon: '➕', label: 'New Lesson', desc: 'Create new lesson' },
      { id: 'main', icon: '📝', label: 'Main Editor', desc: 'Horizontal timeline editing' },
      { id: 'templates', icon: '📋', label: 'Scene Templates', desc: 'Quick scene creation' },
    ]},
    { section: 'Scene Editing', items: [
      { id: 'objectEditor', icon: '🦋', label: 'Object Editor', desc: 'Edit object properties' },
      { id: 'animationPicker', icon: '🎬', label: 'Animation Picker', desc: 'Choose animations' },
      { id: 'questionEditor', icon: '❓', label: 'Question Editor', desc: 'Edit Q&A' },
      { id: 'positioning', icon: '📍', label: 'Positioning', desc: 'Drag & drop layout' },
    ]},
    { section: 'Preview & Validation', items: [
      { id: 'preview', icon: '▶️', label: 'Live Preview', desc: 'Preview with timeline' },
      { id: 'validation', icon: '⚠️', label: 'Validation', desc: 'Check for errors' },
      { id: 'ttsDuration', icon: '⏱️', label: 'TTS Duration', desc: 'Compare languages' },
    ]},
    { section: 'Localization', items: [
      { id: 'localization', icon: '🌐', label: 'Localization', desc: 'All translations' },
    ]},
    { section: 'Import/Export', items: [
      { id: 'export', icon: '📤', label: 'Export', desc: 'Export lesson' },
      { id: 'import', icon: '📥', label: 'Import', desc: 'Import lesson' },
    ]},
    { section: 'Utilities', items: [
      { id: 'shortcuts', icon: '⌨️', label: 'Shortcuts', desc: 'Keyboard shortcuts' },
      { id: 'history', icon: '↩️', label: 'History', desc: 'Undo/Redo history' },
      { id: 'contextMenu', icon: '⋯', label: 'Context Menu', desc: 'Quick actions' },
    ]},
    { section: 'Settings', items: [
      { id: 'lessonSettings', icon: '⚙️', label: 'Lesson Settings', desc: 'Lesson metadata' },
      { id: 'settings', icon: '🔧', label: 'App Settings', desc: 'Editor preferences' },
    ]},
  ];

  return (
    <div style={{ height: '100vh', backgroundColor: colors.background, overflow: 'auto' }}>
      <div style={{
        backgroundColor: colors.primary,
        padding: '24px 20px',
        textAlign: 'center'
      }}>
        <h1 style={{ color: 'white', margin: 0, fontSize: 22 }}>🎬 Lesson Editor</h1>
        <p style={{ color: 'rgba(255,255,255,0.8)', margin: '8px 0 0', fontSize: 13 }}>
          Complete UI/UX Prototypes • 19 Screens
        </p>
      </div>

      <div style={{ padding: '12px 20px' }}>
        {screens.map(section => (
          <div key={section.section} style={{ marginBottom: 20 }}>
            <h3 style={{ 
              fontSize: 12, 
              color: colors.outline, 
              textTransform: 'uppercase',
              letterSpacing: 1,
              marginBottom: 8
            }}>
              {section.section}
            </h3>
            {section.items.map(screen => (
              <button
                key={screen.id}
                onClick={() => onNavigate(screen.id)}
                style={{
                  width: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  padding: '12px',
                  marginBottom: 4,
                  borderRadius: 12,
                  border: 'none',
                  backgroundColor: 'white',
                  cursor: 'pointer',
                  textAlign: 'left'
                }}
              >
                <div style={{
                  width: 40,
                  height: 40,
                  borderRadius: 10,
                  backgroundColor: colors.surfaceContainer,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: 20
                }}>
                  {screen.icon}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 500, fontSize: 14 }}>{screen.label}</div>
                  <div style={{ fontSize: 12, color: colors.outline }}>{screen.desc}</div>
                </div>
                <span style={{ color: colors.outline }}>→</span>
              </button>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
};

// ==================== MAIN APP ====================
export default function LessonEditorPrototype() {
  const [currentScreen, setCurrentScreen] = useState('menu');

  const handleNavigate = (screen) => {
    setCurrentScreen(screen);
  };

  const screens = {
    menu: NavigationMenu,
    lessons: LessonsListScreen,
    newLesson: NewLessonScreen,
    main: MainEditorScreen,
    templates: SceneTemplatesScreen,
    objectEditor: ObjectEditorScreen,
    animationPicker: AnimationPickerScreen,
    questionEditor: QuestionEditorScreen,
    localization: LocalizationScreen,
    ttsDuration: TTSDurationScreen,
    positioning: PositioningScreen,
    preview: LivePreviewScreen,
    validation: ValidationScreen,
    export: ExportScreen,
    import: ImportScreen,
    shortcuts: ShortcutsScreen,
    history: HistoryScreen,
    contextMenu: ContextMenuScreen,
    lessonSettings: LessonSettingsScreen,
    settings: AppSettingsScreen,
  };

  const Screen = screens[currentScreen] || NavigationMenu;

  return (
    <div style={{ 
      maxWidth: 430, 
      margin: '0 auto', 
      height: '100vh',
      boxShadow: '0 0 40px rgba(0,0,0,0.2)',
      overflow: 'hidden',
      position: 'relative'
    }}>
      <Screen onNavigate={handleNavigate} />
    </div>
  );
}
