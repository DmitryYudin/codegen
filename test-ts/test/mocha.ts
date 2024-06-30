import * as glob from 'glob'
import Mocha from 'mocha'
process.env.TS_NODE_PROJECT = 'tsconfig.json'
process.env.TS_CONFIG_PATHS = 'true'
require('ts-mocha')

//
// This file is not automatically rebuild if running mocha as entrypoint
//
const options: Mocha.MochaOptions = {
    timeout: 2 * 60 * 1000,
    reporter: 'spec' // 'dot'
}
const mocha = new Mocha(options)
glob.sync('test/**/**.spec.ts').forEach(f => mocha.addFile(f))

mocha.run((failures) => {
    process.on('exit', () => {
        process.exit(failures)
    })
})

export function getTestTitle (ctx: Mocha.Context | Mocha.Suite) {
    const stack: string[] = []
    let currentCtx: Mocha.Context | Mocha.Suite | undefined = ctx
    while (currentCtx) {
        if ('test' in currentCtx) {
            const ctx = currentCtx as Mocha.Context
            if (ctx.test) {
                stack.push(ctx.test.title)
                currentCtx = ctx.test.parent
            }
        } else {
            const ctx = currentCtx as Mocha.Suite
            if (ctx.title.length) stack.push(ctx.title)
            currentCtx = ctx.parent
        }
    }
    let name = ''
    while (stack.length > 0) {
        name = `${name}>>>> ${stack.pop()} `
    }
    return name
}
