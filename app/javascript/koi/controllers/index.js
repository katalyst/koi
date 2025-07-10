import { application } from "./application";

import content from "@katalyst/content";
application.load(content);

import govuk from "@katalyst/govuk-formbuilder";
application.load(govuk);

import navigation from "@katalyst/navigation";
application.load(navigation);

import tables from "@katalyst/tables";
application.load(tables);

import ClipboardController from "./clipboard_controller";
import FlashController from "./flash_controller";
import FormRequestSubmitController from "./form_request_submit_controller";
import IndexActionsController from "./index_actions_controller";
import KeyboardController from "./keyboard_controller";
import ModalController from "./modal_controller";
import NavigationController from "./navigation_controller";
import NavigationToggleController from "./navigation_toggle_controller";
import PagyNavController from "./pagy_nav_controller";
import ShowHideController from "./show_hide_controller";
import SluggableController from "./sluggable_controller";
import WebauthnAuthenticationController from "./webauthn_authentication_controller";
import WebauthnRegistrationController from "./webauthn_registration_controller";

const Definitions = [
  {
    identifier: "clipboard",
    controllerConstructor: ClipboardController,
  },
  {
    identifier: "flash",
    controllerConstructor: FlashController,
  },
  {
    identifier: "form-request-submit",
    controllerConstructor: FormRequestSubmitController,
  },
  {
    identifier: "index-actions",
    controllerConstructor: IndexActionsController,
  },
  {
    identifier: "keyboard",
    controllerConstructor: KeyboardController,
  },
  {
    identifier: "modal",
    controllerConstructor: ModalController,
  },
  {
    identifier: "navigation",
    controllerConstructor: NavigationController,
  },
  {
    identifier: "navigation-toggle",
    controllerConstructor: NavigationToggleController,
  },
  {
    identifier: "pagy-nav",
    controllerConstructor: PagyNavController,
  },
  {
    identifier: "show-hide",
    controllerConstructor: ShowHideController,
  },
  {
    identifier: "sluggable",
    controllerConstructor: SluggableController,
  },
  {
    identifier: "webauthn-authentication",
    controllerConstructor: WebauthnAuthenticationController,
  },
  {
    identifier: "webauthn-registration",
    controllerConstructor: WebauthnRegistrationController,
  },
];

// dynamically attempt to load hw_combobox_controller, this is an optional dependency
await import("controllers/hw_combobox_controller")
  .then(({ default: HwComboboxController }) => {
    Definitions.push({
      identifier: "hw-combobox",
      controllerConstructor: HwComboboxController,
    });
  })
  .catch(() => null);

application.load(Definitions);
