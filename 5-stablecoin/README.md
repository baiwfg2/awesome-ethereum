## Simple StableCoin DSC

Features supported:
- Deposit collaterals
- mint decentralized stablecoin(DSC)
- liquidation on non-health collaterals


## Fuzz Test

This project supports fuzz tests, which a good testing method for detecting potential edge cases that would cause security vulnerabilities.

Please note there're some subtlties which influences the design of fuzz tests. We want detect as many potential bugs as possible, but we don't want to waste running resource for those obvious reverts. So make some workarounds for normal flows in functions.

# testing coverage on DscEngine smart contract

I add several test cases to make DscEngine.sol's coverage reach above 80% using different mock techniques.

```
╭---------------------------------+------------------+------------------+----------------+----------------╮
| File                            | % Lines          | % Statements     | % Branches     | % Funcs        |
+=========================================================================================================+
| script/DeployDsc.s.sol          | 100.00% (11/11)  | 100.00% (14/14)  | 100.00% (0/0)  | 100.00% (1/1)  |
|---------------------------------+------------------+------------------+----------------+----------------|
| script/HelperConfig.s.sol       | 71.43% (15/21)   | 76.19% (16/21)   | 20.00% (1/5)   | 75.00% (3/4)   |
|---------------------------------+------------------+------------------+----------------+----------------|
| src/DSCEngine.sol               | 89.34% (109/122) | 90.35% (103/114) | 80.00% (8/10)  | 85.29% (29/34) |
|---------------------------------+------------------+------------------+----------------+----------------|
| src/DecentralizedStableCoin.sol | 100.00% (14/14)  | 100.00% (13/13)  | 100.00% (4/4)  | 100.00% (2/2)  |
|---------------------------------+------------------+------------------+----------------+----------------|
| src/libraries/OracleLib.sol     | 70.00% (7/10)    | 75.00% (9/12)    | 0.00% (0/2)    | 50.00% (1/2)   |
|---------------------------------+------------------+------------------+----------------+----------------|
| test/mocks/MockUtils.sol        | 100.00% (10/10)  | 100.00% (6/6)    | 100.00% (0/0)  | 100.00% (4/4)  |
|---------------------------------+------------------+------------------+----------------+----------------|
| Total                           | 88.30% (166/188) | 89.44% (161/180) | 61.90% (13/21) | 85.11% (40/47) |
╰---------------------------------+------------------+------------------+----------------+----------------╯

```