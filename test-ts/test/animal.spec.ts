import { expect, use } from 'chai'
import chaiAsPromised from 'chai-as-promised'
import { getTestTitle } from '@test/mocha'

import * as TYPES from '@generated/types'

describe('Animal type', function () {
    before(function () {
        use(chaiAsPromised)
        // if (disableLogs) setGlobalLogLevel('silent')
    })
    after(function () {
        // if (disableLogs) setGlobalLogLevel('info')
    })

    beforeEach(function () {
        // config.restoreDefaultConfig()
    })

    it('conv-ok', function () {
        console.log(getTestTitle(this))

        const animal: TYPES.Animal = {
            type: 'cat',
            id: 'cat',
            name: 'Tom',
            nickname: 'Tommy',
            age: 100,
            'is-alive': true,
        }
        const str = JSON.stringify(animal)
        expect(() => TYPES.deserializers.animal(str)).not.to.throw()

        const parsed = TYPES.deserializers.animal(str)
        expect(parsed).to.deep.equal(animal)
        // console.log('%o <=> %o', parsed, animal)
        expect(() => TYPES.deserializers.animal(str)).not.to.throw()
    })

    it('conv-fail', function () {
        console.log(getTestTitle(this))
        const animal = {
            type: 'cat',
        }
        const str = JSON.stringify(animal)
        expect(() => TYPES.deserializers.animal(str)).throw()
        /*
        const locationsIn: KAFKA.ProbeTask['source'][] = [
            { uri: 's3:', s3_endpoint_url: 's3.local' },
            { uri: 's3://input/file.mp4', s3_endpoint_url: '' },
            { uri: 's3://input', s3_endpoint_url: 's3.local' },
        ]
        for (const idx in locationsIn) {
            const data: KAFKA.ProbeTask = {
                source: locationsIn[idx],
            }
            expect(() => FromKafka.convProbeTask(data)).throw()
        }
*/
    })
})
