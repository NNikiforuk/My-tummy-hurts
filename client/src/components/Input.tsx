import { Input as MuiInput, InputProps as MuiInputProps } from "@mui/material";

type InputBaseProps = Pick<
	MuiInputProps,
	| "color"
	| "disabled"
	| "error"
	| "margin"
	| "name"
	| "placeholder"
	| "maxRows"
	| "onChange"
	| "required"
	| "type"
	| "value"
>;

type InputProps = InputBaseProps & {
	label: string;
};

export const Input = ({ label, ...rest }: InputProps) => (
	<MuiInput {...rest}>{label}</MuiInput>
);
