package moonshine.components;

import feathers.controls.navigators.TabNavigator;
import moonshine.theme.MoonshineTheme;

class MoonshineTabNavigator extends TabNavigator {

    public function new() {

        super();

        this.variant = MoonshineTheme.THEME_VARIANT_LIGHT_TAB_NAVIGATOR;

    }

}