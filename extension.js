// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require("vscode");
const path = require("path");
const http = require("http");
const { spawn } = require("child_process");
const port = 5691;
// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand("wolfram.Player", () => {
      const { activeTextEditor } = vscode.window;
      if (
        !(
          activeTextEditor && activeTextEditor.document.languageId === "wolfram"
        )
      ) {
        return;
      }
      const { document } = activeTextEditor;
      try {
        spawn("wolframscript", [
          "-f",
          path.join(__dirname, "server.wls"),
          port.toString(),
        ]);
      } catch (e) {
        console.debug(e.message);
      }
      const cellContent = [];
      for (let i = 0; i < document.lineCount; i++) {
        cellContent.push(document.lineAt(i).text);
      }
      const cellContentString = cellContent.join("\n");
      console.debug(cellContentString);
      const req = http.request(
        {
          hostname: "127.0.0.1",
          port,
          path: "/",
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Content-Length": cellContentString.length,
          },
        },
        (res) => {
          res.on("data", (d) => {
            console.debug("msg return %s", d.toString());
          });
        }
      );
      req.write(cellContentString);
    })
  );
}

// This method is called when your extension is deactivated
function deactivate() {}

module.exports = {
  activate,
  deactivate,
};
