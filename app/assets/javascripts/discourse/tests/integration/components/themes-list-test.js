import { click, fillIn, render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import {
  count,
  exists,
  query,
  queryAll,
} from "discourse/tests/helpers/qunit-helpers";
import selectKit from "discourse/tests/helpers/select-kit-helper";
import I18n from "discourse-i18n";
import Theme, { COMPONENTS, THEMES } from "admin/models/theme";

function createThemes(itemsCount, customAttributesCallback) {
  return [...Array(itemsCount)].map((_, i) => {
    const attrs = { name: `Theme ${i + 1}` };
    if (customAttributesCallback) {
      Object.assign(attrs, customAttributesCallback(i + 1));
    }
    return Theme.create(attrs);
  });
}

module("Integration | Component | themes-list", function (hooks) {
  setupRenderingTest(hooks);

  test("current tab is themes", async function (assert) {
    this.themes = createThemes(5);
    this.components = createThemes(5, (n) => {
      return {
        name: `Child ${n}`,
        component: true,
        parentThemes: [this.themes[n - 1]],
        parent_themes: [1, 2, 3, 4, 5],
      };
    });
    this.setProperties({
      themes: this.themes,
      components: this.components,
      currentTab: THEMES,
    });

    await render(
      hbs`<ThemesList @themes={{this.themes}} @components={{this.components}} @currentTab={{this.currentTab}} />`
    );

    assert.strictEqual(
      query(".themes-tab").classList.contains("active"),
      true,
      "themes tab is active"
    );
    assert.strictEqual(
      query(".components-tab").classList.contains("active"),
      false,
      "components tab is not active"
    );

    assert.notOk(
      exists(".inactive-indicator"),
      "there is no inactive themes separator when all themes are inactive"
    );
    assert.strictEqual(
      count(".themes-list-container__item .info"),
      5,
      "displays all themes"
    );

    [2, 3].forEach((num) => this.themes[num].set("user_selectable", true));
    this.themes[4].set("default", true);
    this.set("themes", this.themes);
    const names = [4, 2, 3, 0, 1].map((num) => this.themes[num].get("name")); // default theme always on top, followed by user-selectable ones and then the rest
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.innerText.trim()
      ),
      names,
      "sorts themes correctly"
    );
    assert.strictEqual(
      queryAll(".inactive-indicator").index(),
      3,
      "the separator is in the right location"
    );

    this.themes.forEach((theme) => theme.set("user_selectable", true));
    this.set("themes", this.themes);
    assert.notOk(
      exists(".inactive-indicator"),
      "there is no inactive themes separator when all themes are user-selectable"
    );

    this.set("themes", []);
    assert.strictEqual(
      count(".themes-list-container__item .empty"),
      1,
      "shows one entry with a message when there is nothing to display"
    );
    assert.strictEqual(
      query(".themes-list-container__item span.empty").innerText.trim(),
      I18n.t("admin.customize.theme.empty"),
      "displays the right message"
    );
  });

  test("current tab is components", async function (assert) {
    this.themes = createThemes(5);
    this.components = createThemes(5, (n) => {
      return {
        name: `Child ${n}`,
        component: true,
        parentThemes: [this.themes[n - 1]],
        parent_themes: [1, 2, 3, 4, 5],
      };
    });
    this.setProperties({
      themes: this.themes,
      components: this.components,
      currentTab: COMPONENTS,
    });

    await render(
      hbs`<ThemesList @themes={{this.themes}} @components={{this.components}} @currentTab={{this.currentTab}} />`
    );

    assert.strictEqual(
      query(".components-tab").classList.contains("active"),
      true,
      "components tab is active"
    );
    assert.strictEqual(
      query(".themes-tab").classList.contains("active"),
      false,
      "themes tab is not active"
    );

    assert.notOk(exists(".inactive-indicator"), "there is no separator");
    assert.strictEqual(
      count(".themes-list-container__item .info"),
      5,
      "displays all components"
    );

    this.set("components", []);
    assert.strictEqual(
      count(".themes-list-container__item .empty"),
      1,
      "shows one entry with a message when there is nothing to display"
    );
    assert.strictEqual(
      query(".themes-list-container__item span.empty").innerText.trim(),
      I18n.t("admin.customize.theme.empty"),
      "displays the right message"
    );
  });

  test("themes search is not visible when there are less than 10 themes", async function (assert) {
    const themes = createThemes(9);
    this.setProperties({
      themes,
      currentTab: THEMES,
    });

    await render(
      hbs`<ThemesList @themes={{this.themes}} @components={{(array)}} @currentTab={{this.currentTab}} />`
    );

    assert.ok(
      !exists(".themes-list-search"),
      "search input not shown when we have fewer than 10 themes"
    );
  });

  test("themes search keeps themes whose names include the search term", async function (assert) {
    const themes = ["osama", "OsAmaa", "osAMA 1234"]
      .map((name) => Theme.create({ name: `Theme ${name}` }))
      .concat(createThemes(7));
    this.setProperties({
      themes,
      currentTab: THEMES,
    });

    await render(
      hbs`<ThemesList @themes={{this.themes}} @components={{(array)}} @currentTab={{this.currentTab}} />`
    );

    assert.ok(exists(".themes-list-search__input"));
    await fillIn(".themes-list-search__input", "  oSAma ");
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Theme osama", "Theme OsAmaa", "Theme osAMA 1234"],
      "only themes whose names include the search term are shown"
    );
  });

  test("themes filter", async function (assert) {
    const themes = [
      Theme.create({ name: "Theme enabled 1", user_selectable: true }),
      Theme.create({ name: "Theme enabled 2", user_selectable: true }),
      Theme.create({ name: "Theme disabled 1", user_selectable: false }),
      Theme.create({
        name: "Theme disabled 2",
        user_selectable: false,
        remote_theme: {
          id: 42,
          remote_url:
            "git@github.com:discourse-org/discourse-incomplete-theme.git",
          commits_behind: 1,
        },
      }),
    ];
    this.setProperties({
      themes,
      currentTab: THEMES,
    });

    await render(
      hbs`<ThemesList @themes={{this.themes}} @components={{(array)}} @currentTab={{this.currentTab}} />`
    );

    assert.ok(exists(".themes-list-filter__input"));
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      [
        "Theme enabled 1",
        "Theme enabled 2",
        "Theme disabled 1",
        "Theme disabled 2",
      ]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue("active");
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Theme enabled 1", "Theme enabled 2"]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue("inactive");
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Theme disabled 1", "Theme disabled 2"]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue(
      "updates_available"
    );
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Theme disabled 2"]
    );
  });

  test("components filter", async function (assert) {
    const components = [
      Theme.create({
        name: "Component used 1",
        component: true,
        user_selectable: true,
        parent_themes: [1],
        enabled: true,
      }),
      Theme.create({
        name: "Component used 2",
        component: true,
        user_selectable: true,
        parent_themes: [1],
        enabled: true,
      }),
      Theme.create({
        name: "Component unused 1",
        component: true,
        user_selectable: false,
        parent_themes: [],
        enabled: true,
      }),
      Theme.create({
        name: "Component unused and disabled 1",
        component: true,
        user_selectable: false,
        parent_themes: [],
        enabled: false,
        remote_theme: {
          id: 42,
          remote_url:
            "git@github.com:discourse-org/discourse-incomplete-theme.git",
          commits_behind: 1,
        },
      }),
    ];
    this.setProperties({
      components,
      currentTab: COMPONENTS,
    });

    await render(
      hbs`<ThemesList @themes={{(array)}} @components={{this.components}} @currentTab={{this.currentTab}} />`
    );

    assert.ok(exists(".themes-list-filter__input"));
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      [
        "Component used 1",
        "Component used 2",
        "Component unused 1",
        "Component unused and disabled 1",
      ]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue("active");
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Component used 1", "Component used 2"]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue("inactive");
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Component unused 1", "Component unused and disabled 1"]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue("enabled");
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Component used 1", "Component used 2", "Component unused 1"]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue("disabled");
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Component unused and disabled 1"]
    );

    await selectKit(".themes-list-filter__input").expand();
    await selectKit(".themes-list-filter__input").selectRowByValue(
      "updates_available"
    );
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      ["Component unused and disabled 1"]
    );
  });

  test("switching between themes and components tabs keeps the search visible only if both tabs have at least 10 items", async function (assert) {
    const themes = createThemes(10, (n) => {
      return { name: `Theme ${n}${n}` };
    });
    const components = createThemes(5, (n) => {
      return {
        name: `Component ${n}${n}`,
        component: true,
        parent_themes: [1],
        parentThemes: [1],
      };
    });
    this.setProperties({
      themes,
      components,
      currentTab: THEMES,
    });

    await render(
      hbs`<ThemesList @themes={{this.themes}} @components={{this.components}} @currentTab={{this.currentTab}} />`
    );

    await fillIn(".themes-list-search__input", "11");
    assert.strictEqual(
      query(".themes-list-container__item .info").textContent.trim(),
      "Theme 11",
      "only 1 theme is shown"
    );
    await click(".themes-list-header .components-tab");
    assert.ok(
      !exists(".themes-list-search__input"),
      "search input/term do not persist when we switch to the other" +
        " tab because it has fewer than 10 items"
    );
    assert.deepEqual(
      [...queryAll(".themes-list-container__item .info .name")].map((node) =>
        node.textContent.trim()
      ),
      [
        "Component 11",
        "Component 22",
        "Component 33",
        "Component 44",
        "Component 55",
      ],
      "all components are shown"
    );

    this.set(
      "components",
      this.components.concat(
        createThemes(5, (n) => {
          n += 5;
          return {
            name: `Component ${n}${n}`,
            component: true,
            parent_themes: [1],
            parentThemes: [1],
          };
        })
      )
    );
    assert.ok(
      exists(".themes-list-search__input"),
      "search is now shown for the components tab"
    );

    await fillIn(".themes-list-search__input", "66");
    assert.strictEqual(
      query(".themes-list-container__item .info").textContent.trim(),
      "Component 66",
      "only 1 component is shown"
    );

    await click(".themes-list-header .themes-tab");
    assert.strictEqual(
      query(".themes-list-container__item .info").textContent.trim(),
      "Theme 66",
      "search term persisted between tabs because both have more than 10 items"
    );
  });
});
