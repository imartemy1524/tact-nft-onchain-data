# NFT onchain hardcoded data

## Project structure

-   `contracts` - source code of all the smart contracts of the project and their dependencies.
-   `wrappers` - wrapper classes (implementing `Contract` from ton-core) for the contracts, including any [de]serialization primitives and compilation functions.
-   `tests` - tests for the contracts.
-   `scripts` - scripts used by the project, mainly the deployment scripts.

## What is this project about?

In this project, one tries to implement onchain NFT data generation and serialization.

But unfortunately, it is not yet possible to compile non-utf8 strings in TACT, which leads to the impossibility of hardcoding JPEG/PNG file directly into the smart contract.

