import "htmx-slide/build/style.css";

import "../css/settings.css";
import "../css/colors.css";
import "../css/keyframes.css";
import "../css/view_transitions.css";
import "../css/defaults.css";
import "../css/layout.css";
import "../css/bits/actions.css";
import "../css/bits/breadcrumbs.css";
import "../css/bits/buttons.css";
import "../css/bits/cards.css";
import "../css/bits/containers.css";
import "../css/bits/definition_lists.css";
import "../css/bits/editor.css";
import "../css/bits/empty.css";
import "../css/bits/forms.css";
import "../css/bits/frames.css";
import "../css/bits/headers.css";
import "../css/bits/links.css";
import "../css/bits/loaders.css";
import "../css/bits/pages.css";
import "../css/bits/pills.css";
import "../css/bits/popovers.css";
import "../css/bits/secrets.css";
import "../css/bits/text.css";
import "../css/bits/toggles.css";
import "../css/bits/tooltips.css";
import "../css/pages/dashboard.css";
import "../css/pages/designer.css";
import "../css/pages/devices.css";
import "../css/pages/playlists.css";
import "../css/pages/problem_details.css";

import Alpine from "alpinejs";
import htmx from "htmx.org";

window.Alpine = Alpine;
window.htmx = htmx;

Alpine.start();

import "htmx-ext-sse";
import "htmx-remove";
import "htmx-slide";

import "./code_mirror.js";
