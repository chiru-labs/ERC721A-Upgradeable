#!/usr/bin/env node
const fs = require('fs');
const glob = require('glob');

// rename files
fs.renameSync('contracts/Initializable.sol', 'contracts/ERC721A__Initializable.sol');
fs.renameSync('contracts/InitializableStorage.sol', 'contracts/ERC721A__InitializableStorage.sol');

// loop through all files with contracts/**/*.sol pattern
glob('contracts/**/*.sol', null, function (err, files) {
  files.forEach((file) => {
    // read file content
    const content = fs.readFileSync(file, 'utf8');

    const updatedContent = content
      .replace(/open.*?torage\./g, 'ERC721A.contracts.storage.')
      .replace(/modifier initializer/g, 'modifier initializerERC721A')
      .replace(/initializer\s*?\{/g, 'initializerERC721A {')
      .replace(/modifier onlyInitializing/g, 'modifier onlyInitializingERC721A')
      .replace(/onlyInitializing\s*?\{/g, 'onlyInitializingERC721A {')
      .replace(/Initializable/g, 'ERC721A__Initializable');

    // write updated file
    fs.writeFileSync(file, updatedContent);
  });
});