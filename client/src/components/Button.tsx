import {
	Button as MuiButton,
	ButtonProps as MuiButtonProps,
} from "@mui/material";

type ButtonBaseProps = Pick<
	MuiButtonProps,
	"variant" | "size" | "color" | "disabled" | "startIcon" | "LinkComponent"
>;

type ButtonProps = ButtonBaseProps & {
	label: string;
};

export const Button = ({ label, ...rest }: ButtonProps) => (
	<MuiButton {...rest}>{label}</MuiButton>
);
