#!/bin/bash

# Script to update the UI dashboard with the new uninstaller component
echo "Updating UI dashboard with uninstaller component..."

# Check if the dashboard directory exists
if [ ! -d "ui/dashboard" ]; then
  echo "Error: Dashboard directory not found. Please make sure you're in the correct directory."
  exit 1
fi

# Install dependencies for the dashboard
cd ui/dashboard || exit 1
if [ ! -f "package.json" ]; then
  echo "Error: package.json not found in the dashboard directory."
  exit 1
fi

# Install dependencies
echo "Installing dashboard dependencies..."
npm install

# Build the dashboard
echo "Building the dashboard..."
npm run build

# Return to the root directory
cd ../..

# Update the main package.json if needed
echo "Updating main package.json..."
if [ -f "package.json" ]; then
  # Check if the dashboard script exists
  if ! grep -q "\"dashboard\":" "package.json"; then
    # Add dashboard script to package.json using a temporary file
    sed -i -e '/"scripts": {/a \
    "dashboard": "cd ui/dashboard && npm run dev",' package.json
  fi
fi

echo "Updating test scripts..."
if [ -f "ui/dashboard/package.json" ]; then
  # Add test script to package.json if not present
  if ! grep -q "\"test\":" "ui/dashboard/package.json"; then
    sed -i -e '/"scripts": {/a \
    "test": "jest --config=jest.config.js",' ui/dashboard/package.json
  fi
fi

echo "Creating basic test for uninstaller dashboard component..."
mkdir -p ui/dashboard/tests/components/features

# Create a basic test for the uninstaller dashboard component
cat > ui/dashboard/tests/components/features/UninstallerDashboard.test.jsx << 'EOL'
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import UninstallerDashboard from '../../../components/features/UninstallerDashboard.jsx';

describe('UninstallerDashboard Component', () => {
  test('renders correctly', () => {
    render(<UninstallerDashboard />);
    
    // Check for main heading
    expect(screen.getByText('Cursor AI Editor Uninstaller')).toBeInTheDocument();
    
    // Check for system information section
    expect(screen.getByText('System Information')).toBeInTheDocument();
    
    // Check for action buttons
    expect(screen.getByText('Uninstall Cursor AI')).toBeInTheDocument();
    expect(screen.getByText('Optimize Performance')).toBeInTheDocument();
    expect(screen.getByText('Create Backup')).toBeInTheDocument();
  });

  test('uninstall button triggers progress bar', () => {
    render(<UninstallerDashboard />);
    
    // Click the uninstall button
    fireEvent.click(screen.getByText('Uninstall Cursor AI'));
    
    // Progress should appear
    expect(screen.getByText('Uninstallation Progress')).toBeInTheDocument();
    expect(screen.getByText('0% Complete')).toBeInTheDocument();
  });
});
EOL

echo "UI dashboard update complete!"
echo "You can run the dashboard with: npm run dashboard"

# Show additional information
echo ""
echo "To create a pull request for these changes:"
echo "1. Commit the changes: git add . && git commit -m 'Add uninstaller dashboard component'"
echo "2. Push the changes: git push origin feature/ui-dashboard-integration"
echo "3. Create a pull request on GitHub" 