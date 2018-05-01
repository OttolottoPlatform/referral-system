pragma solidity 0.4.22;


/**
* @dev Ottolotto dao interface.
*/
contract iOttolottoDao {
    /**
    * @dev Compare address with company rule executor.
    */
    function onlyCompany(address) public view returns (bool) {}
}


/**
* @dev OTTO LOTTO Affiliate Program
* Affiliate Program is a unique opportunity for everyone to earn from 
* all games which already are or should appear on our platform! 
* Our program offers competitive terms and you're happy to join! 
* You should earn twice from each person forever - from purchase and from prize!
* When somebody starts playing, using your link, you earn every time 
* he’ll buy a ticket. Percentage of your commission is counted by this table:
* 1 - 10 people - 1% of the ticket price
* 11 - 29  - 2%
* 30 - 49  - 3%
* 50 - 99  - 4%
* 100 - 199  - 5%
* 200 - 299  - 6%
* 300 - 499  - 7%
* 500 - 749  - 8%
* 750 - 999  - 9%
* 1000 people and more 10% of the ticket price
*
* Also, you’ll earn 1% of the game prize each time this person wins!
*/
contract ReferralSystem {
    /**
    * @dev Write info to log about the new referral.
    *
    * @param referral Referral address.
    * @param partner Partner address.
    * @param time The time when the referral was added.
    */
    event ReferralAdded(address indexed referral, address indexed partner, uint256 time);

    /**
    * @dev Write info to log about the new trusted source.
    *
    * @param addedBy Address of the transaction initiator.
    * @param source New source address.
    * @param time The time when the new source was added.
    */
    event AddSource(address indexed addedBy, address source, uint256 time);

    /**
    * @dev Write info to log about the removed source.
    *
    * @param removedBy Address of the transaction initiator.
    * @param source Removed source address.
    * @param time The time when the new source was removed.
    */
    event RemoveSource(address indexed removedBy, address source, uint256 time);

    /**
    * @dev Store referrals.
    */
    mapping(address => address) referrals;

    /**
    * @dev Referrals counter.
    */
    mapping(address => uint256) referralsCounter;

    /**
    * @dev Trusted sources for referrals adding.
    */
    mapping(address => bool) trustedSource;

    /**
    * @dev Ottolotto platform dao.
    */
    iOttolottoDao public dao;
    
    /**
    * @dev Check source.
    *
    * @param source Sender address.
    */
    modifier canAddReferrals(address source) {
        require(trustedSource[source]);
        _;
    }

    /**
    * @dev Verify sender address with dao company address.
    */
    modifier onlyCompany() {
        require(dao.onlyCompany(msg.sender));
        _;
    }

    /**
    * @dev Initialize smart contract.
    */
    constructor() public {
        dao = iOttolottoDao(0x24643A6432721070943a389f0D6445FC3F57e18C);
    }

    /**
    * @dev Add trusted source to storage.
    *
    * @param source Address of the source.
    */
    function addTrustedSource(address source) public onlyCompany() {
        trustedSource[source] = true;
        emit AddSource(msg.sender, source, now);
    }

    /**
    * @dev Remove trusted source from storage.
    *
    * @param source Address of the source.
    */
    function removeTrustedSource(address source) public onlyCompany() {
        trustedSource[source] = false;
        emit RemoveSource(msg.sender, source, now);
    }

    /**
    * @dev Create new referral.
    *
    * @param referral New referral address.
    * @param partner New referral partner address.
    */
    function addReferral(address referral, address partner) 
        public 
        canAddReferrals(msg.sender)
        returns (bool)
    {
        if (referrals[referral] != 0x0) {
            return false;
        }

        referrals[referral] = partner;
        referralsCounter[partner]++;
        
        emit ReferralAdded(referral, partner, now);

        return true;
    }

    /**
    * @dev Get percent by referral system.
    *
    * @param partner Partner address.
    */
    function getPercent(address partner) public view returns (uint8) {
        uint256 count = referralsCounter[partner];

        if (count == 0) { 
            return 0;
        }
        if (count < 10) {
            return 1;
        }
        if (count < 30) {
            return 2;
        }
        if (count < 50) {
            return 3;
        }
        if (count < 100) {
            return 4;
        }
        if (count < 200) {
            return 5;
        }
        if (count < 300) {
            return 6;
        }
        if (count < 500) {
            return 7;
        }
        if (count < 750) {
            return 8;
        }
        if (count < 1000) {
            return 9;
        }

        return 10;
    }

    /**
    * @dev Get partner in referral system by referral address.
    *
    * @param referral Referral address.
    */
    function getPartner(address referral) 
        public
        view
        returns (address)
    {
        return referrals[referral];
    }
}