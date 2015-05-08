# SampleAITest.coffee

require('chai').should()

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.system = {
  addAI: ->
    return
  ai: {}
}

require('../../../../main/public/nz/Graph.coffee')
require('../../../../main/public/nz/GridNode.coffee')

require('../../../../main/public/nz/System.coffee')
require('../../../../main/public/nz/Utils.coffee')
require('../../../../main/public/nz/ai/Param.coffee')
require('../../../../main/public/nz/ai/SampleAI.coffee')


# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'SampleAITest', () ->
