const fs = require('fs');
const path = require('path');

// Components directory
const componentsDir = path.join(__dirname, 'components');

// Function to fix the jsx and global attributes in a file
function fixAttributes(filePath) {
  try {
    // Read the file content
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Define regex patterns for style jsx with true values
    const styleJsxPattern = /<style jsx={true}>/g;
    const styleJsxTruePattern = /<style jsx="true">/g;
    const styleJsxBackticksPattern = /<style jsx={`true`}>/g;
    
    // Define regex patterns for style global with true values
    const styleGlobalPattern = /<style global={true}>/g; 
    const styleGlobalTruePattern = /<style global="true">/g;
    const styleGlobalBackticksPattern = /<style global={`true`}>/g;
    
    // Define combination pattern
    const styleJsxGlobalPattern = /<style jsx global={true}>/g;
    const styleJsxGlobalTruePattern = /<style jsx global="true">/g;
    const styleJsxGlobalBackticksPattern = /<style jsx global={`true`}>/g;
    
    // Check if any patterns match
    const hasStyleJsxIssue = styleJsxPattern.test(content) || 
                            styleJsxTruePattern.test(content) || 
                            styleJsxBackticksPattern.test(content);
                            
    const hasStyleGlobalIssue = styleGlobalPattern.test(content) || 
                               styleGlobalTruePattern.test(content) || 
                               styleGlobalBackticksPattern.test(content);
                               
    const hasStyleJsxGlobalIssue = styleJsxGlobalPattern.test(content) || 
                                  styleJsxGlobalTruePattern.test(content) || 
                                  styleJsxGlobalBackticksPattern.test(content);
    
    // Check if we need to modify the file
    if (hasStyleJsxIssue || hasStyleGlobalIssue || hasStyleJsxGlobalIssue) {
      // Replace style jsx patterns with proper boolean attribute
      content = content.replace(styleJsxPattern, '<style jsx>');
      content = content.replace(styleJsxTruePattern, '<style jsx>');
      content = content.replace(styleJsxBackticksPattern, '<style jsx>');
      
      // Replace style global patterns with proper boolean attribute
      content = content.replace(styleGlobalPattern, '<style global>');
      content = content.replace(styleGlobalTruePattern, '<style global>');
      content = content.replace(styleGlobalBackticksPattern, '<style global>');
      
      // Replace combined jsx global pattern
      content = content.replace(styleJsxGlobalPattern, '<style jsx global>');
      content = content.replace(styleJsxGlobalTruePattern, '<style jsx global>');
      content = content.replace(styleJsxGlobalBackticksPattern, '<style jsx global>');
      
      // Write the fixed content back to the file
      fs.writeFileSync(filePath, content);
      
      console.log(`Fixed attributes in ${path.basename(filePath)}`);
      return true;
    }
    
    return false;
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error);
    return false;
  }
}

// Process all component files
function processComponentFiles() {
  console.log('Checking and fixing jsx and global attributes in component files...');
  
  // Get all jsx files in the components directory
  const files = fs.readdirSync(componentsDir)
    .filter(file => file.endsWith('.jsx'))
    .map(file => path.join(componentsDir, file));
  
  // Add Dashboard.jsx and any other files at the root level
  const rootFiles = [
    path.join(__dirname, 'Dashboard.jsx'),
    path.join(__dirname, 'enhancedDashboard.jsx'),
    path.join(__dirname, 'index.jsx'),
    path.join(__dirname, 'main.jsx')
  ];
  
  // Combine all files to check
  const allFiles = [...files, ...rootFiles].filter(file => fs.existsSync(file));
  
  let fixedCount = 0;
  
  // Process each file
  allFiles.forEach(file => {
    const fixed = fixAttributes(file);
    if (fixed) {
      fixedCount++;
    }
  });
  
  console.log(`Fixed attributes in ${fixedCount} files.`);
}

// Run the script
processComponentFiles();
