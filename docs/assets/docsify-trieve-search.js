(function () {
  /* eslint-disable no-unused-vars */

  function escapeHtml(string) {
    var entityMap = {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;",
    };

    return String(string).replace(/[&<>"']/g, function (s) {
      return entityMap[s];
    });
  }

  var abortController;
  var currentTags;

  /**
   * @param {String} query Search query
   * @returns {Array} Array of results
   */
  async function search(query) {
    if (abortController) abortController.abort();

    abortController = new AbortController();

    let filters = {};

    if (currentTags && Object.keys(currentTags).length) {
      filters.must = [
        {
          field: "tag_set",
          match: currentTags,
        },
      ];
    }

    const response = await fetch(
      `https://api.trieve.ai/api/chunk/autocomplete`,
      {
        method: "POST",
        headers: {
          Authorization: `${CONFIG.api_key}`,
          "TR-Dataset": `${CONFIG.dataset}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          query: query,
          search_type: "semantic",
          highlight_delimiters: [" "],
          highlight_max_length: 100,
          highlight_max_num: 2,
          highlight_window: 20,
          highlight_threshold: 0.9,
          score_threshold: 0.05,
          filters,
        }),
        signal: abortController.signal,
      }
    );

    if (!response.ok) {
      throw new Error("Failed to fetch search results");
    }

    results = await response.json();

    // console.log(results);

    let matches = [];

    results.score_chunks.forEach((chunk) => {
      if (chunk.highlights.length === 0) return;

      title =
        chunk.metadata[0].metadata?.title ?? chunk.metadata[0].tracking_id;
      content = "..." + chunk.highlights.join("<br/>") + "...";
      url = chunk.metadata[0].link.replace(
        /^https?:\/\/[^\/]+\//,
        window.DOCSIFY_ROUTER_MODE == "hash" ? "#/" : "/"
      );

      matches.push({
        title,
        content,
        url,
      });
    });

    return matches;
  }

  /* eslint-disable no-unused-vars */

  var NO_DATA_TEXT = "";
  var options;

  function style() {
    var code =
      "\n.sidebar {\n  padding-top: 0;\n}\n\n.search {\n  margin-bottom: 20px;\n  padding: 6px;\n  border-bottom: 1px solid #eee;\n}\n\n.search .input-wrap {\n  display: flex;\n  align-items: center;\n}\n\n.search .results-panel {\n  display: none;\n}\n\n.search .results-panel.show {\n  display: block;\n}\n\n.search input {\n  outline: none;\n  border: none;\n  width: 100%;\n  padding: 0 7px;\n  line-height: 36px;\n  font-size: 14px;\n  border: 1px solid transparent;\n}\n\n.search input:focus {\n  box-shadow: 0 0 5px var(--theme-color, #42b983);\n  border: 1px solid var(--theme-color, #42b983);\n}\n\n.search input::-webkit-search-decoration,\n.search input::-webkit-search-cancel-button,\n.search input {\n  -webkit-appearance: none;\n  -moz-appearance: none;\n  appearance: none;\n}\n.search .clear-button {\n  cursor: pointer;\n  width: 36px;\n  text-align: right;\n  display: none;\n}\n\n.search .clear-button.show {\n  display: block;\n}\n\n.search .clear-button svg {\n  transform: scale(.5);\n}\n\n.search h2 {\n  font-size: 17px;\n  margin: 10px 0;\n}\n\n.search a {\n  text-decoration: none;\n  color: inherit;\n}\n\n.search .matching-post {\n  border-bottom: 1px solid #eee;\n}\n\n.search .matching-post:last-child {\n  border-bottom: 0;\n}\n\n.search p {\n  font-size: 14px;\n  overflow: hidden;\n  text-overflow: ellipsis;\n  display: -webkit-box;\n  -webkit-line-clamp: 4;\n  -webkit-box-orient: vertical;\n}\n\n.search p.empty {\n  text-align: center;\n}\n\n.app-name.hide, .sidebar-nav.hide {\n  display: none;\n}";

    Docsify.dom.style(code);
  }

  function tpl(defaultValue) {
    if (defaultValue === void 0) defaultValue = "";

    var html =
      '<div class="input-wrap">\n      <input type="search" value="' +
      defaultValue +
      '" aria-label="Search text" />\n      <div class="clear-button">\n        <svg width="26" height="24">\n          <circle cx="12" cy="12" r="11" fill="#ccc" />\n          <path stroke="white" stroke-width="2" d="M8.25,8.25,15.75,15.75" />\n          <path stroke="white" stroke-width="2"d="M8.25,15.75,15.75,8.25" />\n        </svg>\n      </div>\n    </div>\n    <div class="results-panel"></div>\n    </div>';
    var el = Docsify.dom.create("div", html);
    var aside = Docsify.dom.find("aside");

    Docsify.dom.toggleClass(el, "search");
    Docsify.dom.before(aside, el);
  }

  async function doSearch(value) {
    var $search = Docsify.dom.find("div.search");
    var $panel = Docsify.dom.find($search, ".results-panel");
    var $clearBtn = Docsify.dom.find($search, ".clear-button");
    var $sidebarNav = Docsify.dom.find(".sidebar-nav");
    var $appName = Docsify.dom.find(".app-name");

    if (!value) {
      $panel.classList.remove("show");
      $clearBtn.classList.remove("show");
      $panel.innerHTML = "";

      if (options.hideOtherSidebarContent) {
        $sidebarNav.classList.remove("hide");
        $appName.classList.remove("hide");
      }

      return;
    }

    var matchs;

    try {
      matchs = await search(value);
    } catch (e) {
      if (e.name !== "AbortError") {
        console.error(e);
      }
      return;
    }

    var html = "";
    matchs.forEach(function (post) {
      html +=
        '<div class="matching-post">\n<a href="' +
        post.url +
        '">\n<h2>' +
        post.title +
        "</h2>\n<p>" +
        post.content +
        "</p>\n</a>\n</div>";
    });

    $panel.classList.add("show");
    $clearBtn.classList.add("show");
    $panel.innerHTML = html || '<p class="empty">' + NO_DATA_TEXT + "</p>";
    if (options.hideOtherSidebarContent) {
      $sidebarNav.classList.add("hide");
      $appName.classList.add("hide");
    }
  }

  function bindEvents() {
    var $search = Docsify.dom.find("div.search");
    var $input = Docsify.dom.find($search, "input");
    var $inputWrap = Docsify.dom.find($search, ".input-wrap");

    var timeId;

    /**
      Prevent to Fold sidebar.

      When searching on the mobile end,
      the sidebar is collapsed when you click the INPUT box,
      making it impossible to search.
     */
    Docsify.dom.on($search, "click", function (e) {
      return (
        ["A", "H2", "P", "EM"].indexOf(e.target.tagName) === -1 &&
        e.stopPropagation()
      );
    });
    Docsify.dom.on($input, "input", function (e) {
      clearTimeout(timeId);
      timeId = setTimeout(function (_) {
        return doSearch(e.target.value.trim());
      }, 100);
    });
    Docsify.dom.on($inputWrap, "click", function (e) {
      // Click input outside
      if (e.target.tagName !== "INPUT") {
        $input.value = "";
        doSearch();
      }
    });
  }

  function updatePlaceholder(text, path) {
    var $input = Docsify.dom.getNode('.search input[type="search"]');

    if (!$input) {
      return;
    }

    if (typeof text === "string") {
      $input.placeholder = text;
    } else {
      var match = Object.keys(text).filter(function (key) {
        return path.indexOf(key) > -1;
      })[0];
      $input.placeholder = text[match];
    }
  }

  function updateNoData(text, path) {
    if (typeof text === "string") {
      NO_DATA_TEXT = text;
    } else {
      var match = Object.keys(text).filter(function (key) {
        return path.indexOf(key) > -1;
      })[0];
      NO_DATA_TEXT = text[match];
    }
  }

  function updateOptions(opts) {
    options = opts;
  }

  function updateTags(opts, vm) {
    if (vm.config.currentNamespace) {
      namespace = vm.config.currentNamespace.replace(
        /^[^\/]*\/([^\/]+)\//,
        "$1"
      );
      // console.log("Namespace: ", namespace);
      currentTags = CONFIG.namespaceTags[namespace] || CONFIG.tags;
    } else {
      currentDataset = CONFIG.tags;
    }

    // console.log("Tags: ", currentTags);
  }

  function init(opts, vm) {
    var keywords = vm.router.parse().query.s;

    updateTags(opts, vm);
    updateOptions(opts);
    style();
    tpl(keywords);
    bindEvents();
    keywords &&
      setTimeout(function (_) {
        return doSearch(keywords);
      }, 500);
  }

  function update(opts, vm) {
    updateTags(opts, vm);
    updateOptions(opts);
    updatePlaceholder(opts.placeholder, vm.route.path);
    updateNoData(opts.noData, vm.route.path);
  }

  /* eslint-disable no-unused-vars */

  var CONFIG = {
    placeholder: "Type to search",
    noData: "No Results!",
    hideOtherSidebarContent: false,
    api_key: window.TRIEVE_API_KEY,
    dataset: window.TRIEVE_DATASET,
  };

  var install = function (hook, vm) {
    var opts = vm.config.search || CONFIG;

    CONFIG.placeholder = opts.placeholder || CONFIG.placeholder;
    CONFIG.noData = opts.noData || CONFIG.noData;
    CONFIG.hideOtherSidebarContent =
      opts.hideOtherSidebarContent || CONFIG.hideOtherSidebarContent;
    CONFIG.api_key = opts.api_key || CONFIG.api_key;
    CONFIG.dataset = opts.dataset || CONFIG.dataset;
    CONFIG.tags = opts.tags || [];
    CONFIG.namespaceTags = opts.namespaceTags || {};

    hook.mounted(function (_) {
      init(CONFIG, vm);
    });
    hook.doneEach(function (_) {
      update(CONFIG, vm);
    });
  };

  $docsify.plugins = [].concat(install, $docsify.plugins);
})();
