import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { queryAll } from "discourse/tests/helpers/qunit-helpers";

module("Integration | Component | iframed-html", function (hooks) {
  setupRenderingTest(hooks);

  test("appends the html into the iframe", async function (assert) {
    await render(
      hbs`<IframedHtml @html="<h1 id='find-me'>hello</h1>" class="this-is-an-iframe" />`
    );

    const iframe = queryAll("iframe.this-is-an-iframe");
    assert.strictEqual(iframe.length, 1, "inserts an iframe");

    assert.ok(
      iframe[0].classList.contains("this-is-an-iframe"),
      "Adds className to the iframes classList"
    );

    assert.strictEqual(
      iframe[0].contentWindow.document.body.querySelectorAll("#find-me").length,
      1,
      "inserts the passed in html into the iframe"
    );
  });
});
