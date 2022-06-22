package moonshine.components;

import feathers.controls.LayoutGroup;
import moonshine.theme.MoonshineTheme;

class HDivider extends LayoutGroup {

    public function new() {

        super();
        this.variant = MoonshineTheme.THEME_VARIANT_HORIZONTAL_DIVIDER;

    }

}