pragma solidity ^0.4.21;

contract ERC20 {

  function transferFrom(address from, address to, uint value) public returns (bool success);
}

contract Ownable {

  address owner;
  address pendingOwner;

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier onlyPendingOwner {
    require(msg.sender == pendingOwner);
    _;
  }

  function Ownable() public {
    owner = msg.sender;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  function claimOwnership() public onlyPendingOwner {
    owner = pendingOwner;
  }
}

contract Destructible is Ownable {

  function destroy() public onlyOwner {
    selfdestruct(msg.sender);
  }
}

contract WithClaim {

  event Claim(string data);
}

// older version:
// Mainnet: 0xFd74f0ce337fC692B8c124c094c1386A14ec7901
// Rinkeby: 0xC5De286677AC4f371dc791022218b1c13B72DbBd
// Ropsten: 0x6f32a6F579CFEed1FFfDc562231C957ECC894001
// Kovan:   0x139d658eD55b78e783DbE9bD4eb8F2b977b24153

contract UserfeedsClaimWithoutValueTransfer is Destructible, WithClaim {

  function post(string data) public {
    emit Claim(data);
  }
}

// older version:
// Mainnet: 0x70B610F7072E742d4278eC55C02426Dbaaee388C
// Rinkeby: 0x00034B8397d9400117b4298548EAa59267953F8c
// Ropsten: 0x37C1CA7996CDdAaa31e13AA3eEE0C89Ee4f665B5
// Kovan:   0xc666c75C2bBA9AD8Df402138cE32265ac0EC7aaC

contract UserfeedsClaimWithValueTransfer is Destructible, WithClaim {

  function post(address userfeed, string data) public payable {
    emit Claim(data);
    userfeed.transfer(msg.value);
  }
}

// older version:
// Mainnet: 0xfF8A1BA752fE5df494B02D77525EC6Fa76cecb93
// Rinkeby: 0xBd2A0FF74dE98cFDDe4653c610E0E473137534fB
// Ropsten: 0x54b4372fA0bd76664B48625f0e8c899Ff19DFc39
// Kovan:   0xd6Ede7F43882B100C6311a9dF801088eA91cEb64

contract UserfeedsClaimWithTokenTransfer is Destructible, WithClaim {

  function post(address userfeed, ERC20 token, uint value, string data) public {
    emit Claim(data);
    require(token.transferFrom(msg.sender, userfeed, value));
  }
}

// Rinkeby: 0x73cDd7e5Cf3DA3985f985298597D404A90878BD9
// Ropsten: 0xA7828A4369B3e89C02234c9c05d12516dbb154BC
// Kovan:   0x5301F5b1Af6f00A61E3a78A9609d1D143B22BB8d

contract UserfeedsClaimWithValueMultiSendUnsafe is Destructible, WithClaim {

  function post(string data, address[] recipients) public payable {
    emit Claim(data);
    send(recipients);
  }

  function post(string data, bytes20[] recipients) public payable {
    emit Claim(data);
    send(recipients);
  }

  function send(address[] recipients) public payable {
    uint amount = msg.value / recipients.length;
    for (uint i = 0; i < recipients.length; i++) {
      recipients[i].send(amount);
    }
    msg.sender.transfer(address(this).balance);
  }

  function send(bytes20[] recipients) public payable {
    uint amount = msg.value / recipients.length;
    for (uint i = 0; i < recipients.length; i++) {
      address(recipients[i]).send(amount);
    }
    msg.sender.transfer(address(this).balance);
  }
}
