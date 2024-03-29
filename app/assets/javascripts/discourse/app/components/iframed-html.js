import Component from "@ember/component";

export default Component.extend({
  tagName: "iframe",
  html: null,
  classNameBindings: ["html:iframed-html"],
  sandbox: "allow-same-origin",
  attributeBindings: ["sandbox:sandbox"],

  didRender() {
    this._super(...arguments);
    const iframeDoc = this.element.contentWindow.document;
    iframeDoc.open("text/html", "replace");
    iframeDoc.write(this.html);
    iframeDoc.close();
  },
});
