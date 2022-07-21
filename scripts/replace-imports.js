#!/usr/bin/env node
const fs = require('fs');
const glob = require('glob');

// Rename files.
fs.renameSync('contracts/Initializable.sol', 'contracts/ERC721A__Initializable.sol');
fs.renameSync('contracts/InitializableStorage.sol', 'contracts/ERC721A__InitializableStorage.sol');

// Loop through all files with contracts/**/*.sol pattern.
glob('contracts/**/*.sol', null, function (err, files) {
  files.forEach((file) => {
    // Read file content.
    const content = fs.readFileSync(file, 'utf8');

    const updatedContent = content
      .replace(/open.*?torage\./g, 'ERC721A.contracts.storage.')
      .replace(/modifier initializer/g, 'modifier initializerERC721A')
      .replace(/initializer\s*?\{/g, 'initializerERC721A {')
      .replace(/modifier onlyInitializing/g, 'modifier onlyInitializingERC721A')
      .replace(/onlyInitializing\s*?\{/g, 'onlyInitializingERC721A {')
      .replace(/Initializable/g, 'ERC721A__Initializable');

    // Write updated file.
    fs.writeFileSync(file, updatedContent);
  });
});

// Replace the TokenApprovalRef to break cyclic importing.
let erc721aFilepath = 'contracts/ERC721AUpgradeable.sol';
let erc721aContents = fs.readFileSync(erc721aFilepath, 'utf8');
let tokenApprovalRefRe = /\/\/.*?\n\r?\s*struct TokenApprovalRef\s*\{[^}]+\}/;
let tokenApprovalRefMatch = erc721aContents.match(tokenApprovalRefRe);
if (tokenApprovalRefMatch) {
  erc721aContents = erc721aContents
    .replace(tokenApprovalRefMatch[0], '')
    .replace(/TokenApprovalRef/g, 'ERC721AStorage.TokenApprovalRef');
  fs.writeFileSync(erc721aFilepath, erc721aContents);

  let erc721aStorageFilepath = 'contracts/ERC721AStorage.sol';
  let erc721aStorageContents = fs.readFileSync(erc721aStorageFilepath, 'utf8');
  erc721aStorageContents = erc721aStorageContents
    .replace(/struct Layout\s*\{/, tokenApprovalRefMatch[0] + '\n\n    struct Layout {')
    .replace(/ERC721AUpgradeable.TokenApprovalRef/g, 'ERC721AStorage.TokenApprovalRef')
    .replace(/import.*?\.\/ERC721AUpgradeable.sol[^;]+;/, '');
  
  fs.writeFileSync(erc721aStorageFilepath, erc721aStorageContents);
}
