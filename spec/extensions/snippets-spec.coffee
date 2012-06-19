Snippets = require 'snippets'
RootView = require 'root-view'
Buffer = require 'buffer'
Editor = require 'editor'
_ = require 'underscore'

fdescribe "Snippets extension", ->
  [buffer, editor] = []
  beforeEach ->
    rootView = new RootView(require.resolve('fixtures/sample.js'))
    editor = rootView.activeEditor()
    buffer = editor.buffer
    rootView.activateExtension(Snippets)
    rootView.simulateDomAttachment()

  describe "when 'tab' is triggered on the editor", ->
    describe "when the letters preceding the cursor are registered as a global extension", ->
      it "replaces the prefix with the snippet text", ->
        Snippets.evalSnippets 'js', """
          snippet te "Test snippet description"
          this is a test
          endsnippet
        """
        editor.insertText("te")
        expect(editor.getCursorScreenPosition()).toEqual [0, 2]

        editor.trigger 'tab'
        expect(buffer.lineForRow(0)).toBe "this is a testvar quicksort = function () {"
        expect(editor.getCursorScreenPosition()).toEqual [0, 14]

  describe "Snippets parser", ->
    it "can parse multiple snippets", ->
      snippets = Snippets.snippetsParser.parse """
        snippet t1 "Test snippet 1"
        this is a test 1
        endsnippet

        snippet t2 "Test snippet 2"
        this is a test 2
        endsnippet
      """
      expect(_.keys(snippets).length).toBe 2
      snippet = snippets['t1']
      expect(snippet.prefix).toBe 't1'
      expect(snippet.description).toBe "Test snippet 1"
      expect(snippet.body).toBe "this is a test 1"

      snippet = snippets['t2']
      expect(snippet.prefix).toBe 't2'
      expect(snippet.description).toBe "Test snippet 2"
      expect(snippet.body).toBe "this is a test 2"
