import { basicSetup } from "codemirror";
import { EditorView, keymap } from "@codemirror/view";
import { EditorState } from "@codemirror/state";
import { oneDark } from "@codemirror/theme-one-dark";
import { indentWithTab, indentSelection } from "@codemirror/commands";
import { json } from "@codemirror/lang-json";
import { liquid } from "@codemirror/lang-liquid";

function initializeCodeMirror() {
  const languages = {
    json: json(),
    liquid: liquid()
  };

  document.querySelectorAll(".bit-editor").forEach((element) => {
    if (element.dataset.initialized) return;

    let code = element.value;
    let language = element.dataset.language;
    let readable = element.dataset.mode === "read";
    let container = document.createElement("div");
    let extensions = [
      basicSetup,
      oneDark,
      keymap.of([indentWithTab, indentSelection]),
      EditorState.readOnly.of(readable),
      EditorView.lineWrapping,
      EditorView.theme(
        {
          "&": {
            minHeight: "10rem",
            maxHeight: "25rem"
          },
          ".cm-scroller": {
            overflow: "auto"
          }
        }
      ),
      EditorView.updateListener.of((update) => {
        if (update.docChanged) {
          element.value = update.state.doc.toString();
        }
      })
    ];

    if (languages[language]) {
      extensions.push(languages[language]);
    }

    container.className = "cm-container";
    element.style.display = "none";
    element.parentNode.insertBefore(container, element.nextSibling);

    new EditorView({
      doc: code,
      extensions: extensions,
      parent: container
    });

    element.dataset.initialized = "true";
  });
}

document.addEventListener("htmx:after:process", function(event) {
  initializeCodeMirror();
});
