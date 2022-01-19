pragma solidity >=0.5.0;

import "contracts/token/KIP17/IKIP17.sol";
import "contracts/token/KIP17/IKIP17Enumerable.sol";
import "contracts/token/KIP17/IKIP17Metadata.sol";

/**
 * @title KIP-17 Non-Fungible Token Standard, full implementation interface
 * @dev See http://kips.klaytn.com/KIPs/kip-17-non_fungible_token
 */
contract IKIP17Full is IKIP17, IKIP17Enumerable, IKIP17Metadata {
    // solhint-disable-previous-line no-empty-blocks
}
