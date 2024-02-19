import { configureStore } from "@reduxjs/toolkit";
import inputsReducerLogin from "./login/inputsLoginSlice";
import inputsReducerRegister from "./register/inputsRegisterSlice";

export const store = configureStore({
	reducer: {
		inputsLogin: inputsReducerLogin,
		inputsRegister: inputsReducerRegister,
	},
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
