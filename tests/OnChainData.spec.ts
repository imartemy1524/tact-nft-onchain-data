import { Blockchain, printTransactionFees, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Cell, toNano, TupleReader } from '@ton/core';
import { OnChainDataNFT } from '../wrappers/OnChainData';
import '@ton/test-utils';
import { decodeNftDataOnchain } from './helpers';
import { readFile } from 'node:fs/promises';
import { readFileSync } from 'fs';
import { Slice } from '@ton/core/src/boc/Slice';
const img = readFileSync(__dirname + '/../contracts/img.png', {encoding: 'binary'});

describe('OnChainData', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let onChainData: SandboxContract<OnChainDataNFT>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        onChainData = blockchain.openContract(await OnChainDataNFT.fromInit());

        deployer = await blockchain.treasury('deployer');

        const { transactions } = await onChainData.send(
            deployer.getSender(),
            {
                value: toNano('100'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );
        expect(transactions).toHaveTransaction({
            from: deployer.address,
            to: onChainData.address,
            deploy: true,
            success: true,
        });
    });
    it('text', async ()=>{
        const fileBin = img;
        // under the hood one decodes buffer as utf-8 string
        const invalidBinary = await onChainData.getAvatarBinary();
        expect(invalidBinary).toEqual(fileBin);

        //and here one decodes buffer as binary string
        const source = await blockchain.runGetMethod(onChainData.address, 'avatar_binary').then(e=>e.stack);
        const reader = new TupleReader(source);
        //@ts-ignore
        const bufferData = readBuffer(reader.readCell().beginParse());

        //this should not pass, but it passes
        expect(bufferData?.toString('utf-8')).toEqual(fileBin);
        //ans this SHOULD, but it doesn't
        expect(bufferData?.toString('binary')).toEqual(fileBin);
    })
    it('should deploy', async () => {
        const { individual_content: snake } = await onChainData.getGetNftData_2(true);
        const {individual_content: dict} = await onChainData.getGetNftData_2(false);
        const dataSnake = decodeNftDataOnchain(snake);
        const dataDict = decodeNftDataOnchain(dict);
        expect(dataDict.name).toEqual(dataSnake.name);
        expect(dataDict.description).toEqual(dataSnake.description);

        expect(dataDict.image_data).toEqual(dataSnake.image_data);
        console.warn("Next check would fail, because tact doen't support binary data yet, but it should pass, if one decodes string data as binary string")

        expect(dataDict.image_data?.equals(Buffer.from(img, 'binary'))).toBeTruthy();

    });
});



function readBuffer(slice: Slice) {
    // Check consistency
    if (slice.remainingBits % 8 !== 0) {
        throw new Error(`Invalid string length: ${slice.remainingBits}`);
    }
    if (slice.remainingRefs !== 0 && slice.remainingRefs !== 1) {
        throw new Error(`invalid number of refs: ${slice.remainingRefs}`);
    }

    // Read string
    let res: Buffer
    if (slice.remainingBits === 0) {
        res = Buffer.alloc(0);
    } else {
        res = slice.loadBuffer(slice.remainingBits / 8);
    }

    // Read tail
    if (slice.remainingRefs === 1) {
        res = Buffer.concat([res, readBuffer(slice.loadRef().beginParse())]);
    }

    return res;
}