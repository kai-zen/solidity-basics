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

## Scripts

| Script           | Command                  | Description                          |
|------------------|--------------------------|--------------------------------------|
| Compile          | `pnpm run compile`       | Build contracts (Hardhat)            |
| Test             | `pnpm run test`          | Run Solidity tests                   |
| Solidity test    | `pnpm run solidity-test` | Run Solidity tests (explicit)        |
| Coverage         | `pnpm run coverage`      | Run tests with coverage              |
| Local deploy     | `pnpm run local-deploy`  | Deploy to localhost via Ignition     |

## Build

```bash
pnpm run compile
```

## Tests

Tests are written with **Foundry** (Forge) in `contracts/MyToken.t.sol` and run through Hardhat:

```bash
pnpm run test
```

The suite’t The suite covers:

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
