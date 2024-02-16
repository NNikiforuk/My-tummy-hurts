import { createSlice, PayloadAction } from "@reduxjs/toolkit";

export interface InputsState {
	email: string;
	password: string;
}

const initialState: InputsState = {
	email: "",
	password: "",
};

export const inputsSlice = createSlice({
	name: "inputs",
	initialState,
	reducers: {
		setInputs: (
			state,
			action: PayloadAction<{ field: keyof InputsState; value: string }>
		) => {
			const { field, value } = action.payload;
			state[field] = value;
		},
	},
});

export const { setInputs } = inputsSlice.actions;
export default inputsSlice.reducer;
