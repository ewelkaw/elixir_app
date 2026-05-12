// Phoenix LiveView client. Establishes a WebSocket to the server, applies
// HTML diffs, dispatches phx-click / phx-submit events.
//
// For Python folks: nothing like this exists in Django/Flask out of the box —
// the closest comparison is HTMX, but LiveView is more integrated and uses
// minimal-payload diffs computed on the server.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});

liveSocket.connect();
window.liveSocket = liveSocket;
