# ERC20 Token

A minimal, from-scratch ERC20 token implementation in Solidity. No OpenZeppelin—just the core spec: transfers, approvals, and optional mint/burn internals.

## Features

- **Standard ERC20**: `transfer`, `approve`, `transferFrom`, `balanceOf`, `allowance`, `totalSupply`
- **Metadata**: configurable `name`, `symbol`, and `decimals` in the constructor
- **Events**: `Transfer` and `Approval` as per the spec
- **Internal helpers**: `_mint` and `_burn` for extensions or owner-only logic
- **Solidity 0.8.28** with simple custom errors / require messages

## Project structure

```
ERC20/
├── contracts/
│   ├── MyToken.sol      # ERC20 implementation
│   └── MyToken.t.sol    # Foundry tests
├── hardhat.config.ts
├── package.json
└── README.md
```

## Requirements

- [Node.js](https://nodejs.org/) (v18+)
- [pnpm](https://pnpm.io/) (or npm/yarn)

## Setup

```bash
pnpm install
```

## Build

```bash
npx hardhat compile
```

## Tests

Tests are written with **Foundry** (Forge) in `contracts/MyToken.t.sol`. Run them with:

```bash
forge test
```

If you don’t have Foundry yet:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

The suite covers:

- Deployment (name, symbol, decimals, total supply, initial balance)
- `transfer` (including revert on zero address / insufficient balance)
- `approve` and allowance updates
- `transferFrom` and allowance deduction
- Fuzz tests for `transfer` and `transferFrom`
- Mint and burn behavior (for when you expose `mint`/`burn` or use the internals)

## Usage

Deploy with constructor args:

- `_name`: Token name (e.g. `"My Token"`)
- `_symbol`: Symbol (e.g. `"MTK"`)
- `_decimals`: Usually `18`
- `_initialSupply`: Amount in human-readable units (e.g. `1_000_000` for 1M tokens with 18 decimals)

The deployer receives the full initial supply.

## License

MIT
