import { application } from "koi/controllers/application";

import content from "@katalyst/content";
application.load(content);

import navigation from "@katalyst/navigation";
application.load(navigation);

import tables from "@katalyst/tables";
application.load(tables);

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom("controllers", application);
eagerLoadControllersFrom("koi/controllers", application);
