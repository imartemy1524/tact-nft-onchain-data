import "@stdlib/deploy";
import "./img.png.tact";
import "@stdlib/ownable";
import "./json.tact";
//one unable to do this...
//const data: String = readFile("./image.webp");
//so have to do this
struct GetNftData {
    is_initialized: Bool;
    index: Int;
    collection_address: Address;
    owner_address: Address;
    individual_content: Cell;
}
struct RoyaltyParams {
    numerator: Int;
    denominator: Int;
    destination: Address;
}

message(0x05138d91) OwnershipAssigned {
    query_id: Int as uint64;
    prev_owner: Address;
    forward_payload: Slice as remaining;
}
message(0x8b771735) ReportStaticData {
    query_id: Int as uint64;
    index_id: Int;
    collection: Address;
}
message(0x5fcc3d14) Transfer {
    query_id: Int as uint64;
    new_owner: Address;
    response_destination: Address?;
    custom_payload: Cell?;
    forward_amount: Int as coins;
    forward_payload: Slice as remaining;
}

message(0xd53276db) Excesses {
    query_id: Int as uint64;
}
message(0x2fcb26a2) GetStaticData {
    query_id: Int as uint64;
}

struct ElString{value: String;}


const NullAddress: Address = address("0:0000000000000000000000000000000000000000000000000000000000000000");
//Hardcoded values
fun buildContent(snakeCell: Bool): Cell {
    let data: map<Int, ElString> = emptyMap();

    data.set(sha256("name"), ElString{value: "Bob"});
    data.set(sha256("image_data"), ElString{ value: img});
    data.set(sha256("description"), ElString{ value: "NFT with onchain data, bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............. I need a really long-long string, that ould be stored in the blockchain, s.t. it would be stored in many cells/dicts, to test splitting data and joining it back...... bla bla bla bla bla bla bla bla............."});
    data.set(sha256("attributes"), ElString{ value:
        createJsonArray()
            .appendObject(
                createJsonObject()
                    .appendString("trait_type", "Popularity")
                    .appendString("value", "100%")
            )
            .appendObject(
                createJsonObject()
                    .appendString("trait_type", "Age")
                    .appendString("value", "25")
            )
        .toString()
    });
    let ans = buildData(data, snakeCell);
    return ans;
}

//Store nft text as snake cell
inline fun nftTextToCellAsMultiref(input: String): Cell {
    let slice: Slice = input.asSlice();

    let builder = beginString()
    //   write "0" as uint
        .concat("\x00")
    //   write input as string (s.t. cell refs would be recalculated)
        .concat(input);
    return builder.toString().asSlice().asCell();

}
//Store nft text as a dict cell

inline fun nftTextToCellAsDict(input: String): Cell{
    let dict: map<Int as uint32, Cell> = emptyMap();
    let curr: Slice = input.asSlice();
    let valid = true;
    let i = 0;
    while(valid){
        dict.set(i, curr.loadBits(curr.bits()).asCell());
        i += 1;
        valid = !curr.refsEmpty();
        if(valid){
            curr = curr.loadRef().asSlice();
        }
    }

    return beginCell()
    //1 - chunk dict
        .storeUint(1, 8)
        .storeBool(true)
        .storeRef(dict.asCell()!!)
        .asCell();

}
inline fun nftTextToCell(input: String, storeAsSnake: Bool): Cell {
    if(storeAsSnake) {
        return nftTextToCellAsMultiref(input);
    }
    return nftTextToCellAsDict(input);
}
inline fun buildData(content: map<Int, ElString>, asSnake: Bool): Cell{
    let ans: map<Int as uint256, Cell> = emptyMap();
    foreach(key, value in content){
        //
        ans.set(key,nftTextToCell(value.value, asSnake));
    }
    return beginCell().storeInt(0, 8).storeBool(true).storeRef(ans.asCell()!!).endCell()
    //    OnChainData{
    //        byte: 0,
    //        data: ans
    //    }.toCell();
}

contract OnChainDataNFT with Deployable, Ownable {
    override const storageReserve: Int = ton("0.1");
    owner: Address;
    const ComputeFee: Int = ton("0.011");

    // Empty init() function is present by default in all Tact contracts
    // since v1.3.0, so the following may be omitted:

    init() {
        self.owner = context().sender;
     }

    get fun get_nft_data(): GetNftData{
        return GetNftData{
            is_initialized: true,
            index: 1000,
            collection_address: NullAddress,
            owner_address: self.owner,
            // lets use dictionary format
            individual_content: buildContent(false)
        };
    }
    get fun get_nft_data_2(b: Bool): GetNftData{
        return GetNftData{
            is_initialized: true,
            index: 1000,
            collection_address: NullAddress,
            owner_address: self.owner,
            individual_content: buildContent(b)
        };
    }
    receive(msg: GetStaticData){
        let ctx: Context = context();
        send(SendParameters {
            to: ctx.sender,
            value: 0,
            mode: SendRemainingValue,  // (return msg amount except gas fees)
            bounce: true,
            body: ReportStaticData{query_id: msg.query_id, index_id: -1, collection: NullAddress}.toCell()
        });
    }
    receive(msg: Transfer){
        self.requireOwner();
        let ctx: Context = context(); // Reference: https://docs.tact-lang.org/language/ref/common#context

        self.owner = msg.new_owner;  // change current owner to the new_owner
        //f@cking work with comissions... IDK, how it works
        let msgValue: Int = self.msgValue(ctx.value);
        if (msg.forward_amount > 0) {
            send(SendParameters{
                    to: msg.new_owner,
                    value: msg.forward_amount,
                    mode: SendPayGasSeparately,
                    bounce: true,
                    body: OwnershipAssigned{
                    query_id: msg.query_id,
                    prev_owner: ctx.sender,
                    forward_payload: msg.forward_payload
                }.toCell()
            });
        }

        msgValue -= ctx.readForwardFee();
        if (msg.response_destination != null) {
            send(SendParameters{
            to: msg.response_destination!!,
            value: msgValue - msg.forward_amount,
            mode: SendPayGasSeparately,
            bounce: true,
            body: Excesses{
            query_id: msg.query_id }.toCell()
            });
        }
    }
    inline fun msgValue(value: Int): Int {
        let tonBalanceBeforeMsg: Int = myBalance() - value;
        let storageFee: Int = self.storageReserve - min(tonBalanceBeforeMsg, self.storageReserve);
        return value - (storageFee + self.ComputeFee);
    }
    get fun royalty_params(): RoyaltyParams {
        return RoyaltyParams{
            numerator: 100,
            denominator: 100_00,
            destination: self.owner
        };
    }
    get fun avatar_binary(): String{
        return img;
    }
}
