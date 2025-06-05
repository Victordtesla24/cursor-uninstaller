// Mock UI components for testing
export const MockSettingsPanel = ({
  settings = {},
  tokenBudgets = {},
  onSettingChange = () => {},
  onBudgetChange = () => {}
}) => {
  const mockElement = {
    type: 'div',
    props: {
      'data-testid': 'settings-panel',
      className: 'mock-settings-panel'
    },
    children: []
  };

  // Add title
  mockElement.children.push({ type: 'h2', children: ['Settings'] });

  // Add settings items
  const settingsContainer = {
    type: 'div',
    props: { className: 'settings-items' },
    children: []
  };

  if (settings && typeof settings === 'object') {
    Object.keys(settings).forEach(key => {
      const settingItem = {
        type: 'div',
        props: {
          className: 'setting-item',
          'data-setting-id': key
        },
        children: [
          { type: 'span', children: [key] },
          {
            type: 'input',
            props: {
              type: 'checkbox',
              checked: settings[key],
              onChange: () => onSettingChange(key, !settings[key]),
              'data-testid': `setting-${key}`
            }
          }
        ]
      };
      settingsContainer.children.push(settingItem);
    });
  }

  mockElement.children.push(settingsContainer);

  // Add budget items
  const budgetContainer = {
    type: 'div',
    props: { className: 'budget-items' },
    children: []
  };

  if (tokenBudgets && typeof tokenBudgets === 'object') {
    Object.keys(tokenBudgets).forEach(key => {
      const budgetItem = {
        type: 'div',
        props: {
          className: 'budget-item',
          'data-budget-id': key
        },
        children: [
          { type: 'span', children: [key] },
          { type: 'span', children: [tokenBudgets[key]] },
          {
            type: 'button',
            props: {
              onClick: () => onBudgetChange(key, tokenBudgets[key] + 100),
              'data-testid': `budget-edit-${key}`
            },
            children: ['Edit']
          }
        ]
      };
      budgetContainer.children.push(budgetItem);
    });
  }

  mockElement.children.push(budgetContainer);
  return mockElement;
};

// Add other mock components as needed
