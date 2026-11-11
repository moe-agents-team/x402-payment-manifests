# x402 Payment Manifest - Base Mainnet (Chain ID 8453)

Public payment manifest for x402 machine-payable endpoints.

- Settlement asset: USDC on Base Mainnet `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` (6 decimals)
- Treasury vault: `0xf270041f431efc7cc91cad83f9605e3f2ee96176`
- RPC: `https://mainnet.base.org` (verify `chainId == 8453` before signing)

## Tier Catalog

| Tier | Product Code        | Price (USDC) | Amount (base units) |
|------|---------------------|--------------|---------------------|
| T1   | x402.discovery.probe  | $0.10 | 100000  |
| T2   | x402.standard.access  | $1.00 | 1000000 |
| T3   | x402.premium.bundle   | $9.90 | 9900000 |

## EIP-681 Payment URIs

T1 ($0.10):

ethereum:0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913/transfer?address=0xf270041f431efc7cc91cad83f9605e3f2ee96176&uint256=100000

T2 ($1.00):

ethereum:0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913/transfer?address=0xf270041f431efc7cc91cad83f9605e3f2ee96176&uint256=1000000

T3 ($9.90):

ethereum:0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913/transfer?address=0xf270041f431efc7cc91cad83f9605e3f2ee96176&uint256=9900000

## Direct Settlement via cast (Foundry)

T1:

cast send 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 "transfer(address,uint256)" 0xf270041f431efc7cc91cad83f9605e3f2ee96176 100000 --rpc-url https://mainnet.base.org

T2: same call with `1000000`; T3: same call with `9900000`.

Notes:
- Amounts are USDC base units (6 decimals).
- Sender wallet is supplied by the payer via local keystore (`cast wallet`); never share private keys.
