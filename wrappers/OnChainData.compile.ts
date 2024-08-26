import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/on_chain_data.tact',
    options: {
        debug: true,
    },
};
