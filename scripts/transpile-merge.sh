git checkout main;

# Download the latest ERC721A.
if [[ -f "ERC721A/package.json" ]]; then
	cd ERC721A;
	git fetch --all; 
	git reset --hard origin/main;
	cd ..;
else
	git clone https://github.com/chiru-labs/ERC721A.git;
fi

# Replace the contracts folder with the latest copy.
rm -r ./contracts;
rm -r @openzeppelin;
rsync -av --progress ERC721A/ ./ \
	--exclude README.md \
	--exclude hardhat.config.js \
	--exclude .github/ \
	--exclude .git/ \
	--exclude package.json \
	--exclude package-lock.json;

# Recompile the contracts.
rm -r artifacts;
npx hardhat compile;

# Transpile.
npx @openzeppelin/upgrade-safe-transpiler@latest -D
node scripts/replace-imports.js;
rm -r contracts/Initializable.sol;
rm -r @openzeppelin;


# Get the last commit hash of ERC721A
cd ./ERC721A;
commit="$(git rev-parse HEAD)";
cd ..;
rm -rf ./ERC721A;

: '
# Commit and push
git config user.name 'github-actions';
git config user.email '41898282+github-actions[bot]@users.noreply.github.com';
git add -A;
(git commit -m "Transpile chiru-labs/ERC721A@$commit" && git push origin main) || echo "No changes to commit";
'
