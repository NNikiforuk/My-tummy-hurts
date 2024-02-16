import { configureStore } from "@reduxjs/toolkit";
import inputsReducer from "./login/inputsSlice";

export const store = configureStore({
	reducer: {
		inputs: inputsReducer,
	},
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
