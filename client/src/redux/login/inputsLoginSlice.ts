import { createSlice, PayloadAction } from "@reduxjs/toolkit";

export interface InputsLoginState {
	email: string;
	password: string;
}

const initialState: InputsLoginState = {
	email: "",
	password: "",
};

export const inputsLoginSlice = createSlice({
	name: "inputsLogin",
	initialState,
	reducers: {
		setLoginInputs: (
			state,
			action: PayloadAction<{ field: keyof InputsLoginState; value: string }>
		) => {
			const { field, value } = action.payload;
			state[field] = value;
		},
	},
});

export const { setLoginInputs } = inputsLoginSlice.actions;
export default inputsLoginSlice.reducer;
