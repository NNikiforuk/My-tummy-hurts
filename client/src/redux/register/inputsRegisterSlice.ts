import { createSlice, PayloadAction } from "@reduxjs/toolkit";

export interface InputsRegisterState {
	email: string;
	name: string;
	password: string;
}

const initialState: InputsRegisterState = {
	email: "",
	name: "",
	password: "",
};

export const inputsRegisterSlice = createSlice({
	name: "inputsRegister",
	initialState,
	reducers: {
		setRegisterInputs: (
			state,
			action: PayloadAction<{ field: keyof InputsRegisterState; value: string }>
		) => {
			const { field, value } = action.payload;
			state[field] = value;
		},
	},
});

export const { setRegisterInputs } = inputsRegisterSlice.actions;
export default inputsRegisterSlice.reducer;
