import { Blockchain, printTransactionFees, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Cell, toNano } from '@ton/core';
import { OnChainDataNFT } from '../wrappers/OnChainData';
import '@ton/test-utils';
import { decodeNftDataOnchain } from './helpers';
import { readFile } from 'node:fs/promises';
import { readFileSync } from 'fs';
const img = readFileSync(__dirname + '/../contracts/img.png');

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
        const fileBin = img.toString('binary');
        const image = await onChainData.getAvatarBinary();
        expect(image).toEqual(fileBin);
    })
    it('should deploy', async () => {
        const { individual_content: snake } = await onChainData.getGetNftData_2(true);
        const {individual_content: dict} = await onChainData.getGetNftData_2(false);
        const dataSnake = decodeNftDataOnchain(snake);
        const dataDict = decodeNftDataOnchain(dict);
        expect(dataDict.name).toEqual(dataSnake.name);
        expect(dataDict.description).toEqual(dataSnake.description);
        expect(dataDict.image_data).toEqual(dataSnake.image_data);
        dataSnake.image_data
        // console.log('NFT Content: ', data);
        // console.log("Image data: ", data.image_data?.toString());

        //read contracts/img.png as buffer
        // expect(data.image_data?.equals(img)).toBeTruthy();
    });
});


