import "@fontsource/roboto/300.css";
import "@fontsource/roboto/400.css";
import "@fontsource/roboto/500.css";
import "@fontsource/roboto/700.css";
import "@fontsource/material-icons";
import type { Preview } from "@storybook/react";
// import { CssBaseline, ThemeProvider } from "@mui/material";
// import { withThemeFromJSXProvider } from "@storybook/addon-themes";
// import { lightTheme, darkTheme } from "../src/utils/themes.ts";

// export const decorators = [
// 	withThemeFromJSXProvider({
// 		themes: {
// 			light: lightTheme,
// 			dark: darkTheme,
// 		},
// 		defaultTheme: "light",
// 		Provider: ThemeProvider,
// 		GlobalStyles: CssBaseline,
// 	}),
// ];

const preview: Preview = {
	parameters: {
		actions: { argTypesRegex: "^on[A-Z].*" },
		controls: {
			expanded: true,
			matchers: {
				color: /(background|color)$/i,
				date: /Date$/i,
			},
		},
	},
};

export default preview;
