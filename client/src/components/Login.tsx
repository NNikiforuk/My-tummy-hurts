import { useState } from "react";
import { Button } from "./Button";
import { Input } from "./Input";

const Login = () => {
	const [inputsValue, setInputValue] = useState({
		email: "",
		password: "",
	});
	const { email, password } = inputsValue;

	const onChange = (e: { target: { name: string; value: string } }) => {
		setInputValue({ ...inputsValue, [e.target.name]: e.target.value });
	};

	const onSubmitForm = () => {};

	return (
		<section className="login">
			<h1>Log in</h1>
			<form onSubmit={onSubmitForm}>
				<Input
					type="email"
					name="email"
					placeholder="Enter e-mail"
					value={email}
					onChange={(e) => onChange(e)}
					label="Email"
				/>
				<Input
					type="password"
					name="password"
					placeholder="Enter password"
					value={password}
					onChange={(e) => onChange(e)}
					label="Password"
				/>
			</form>
			<Button label="Log in" color="primary" size="small" variant="contained" />
		</section>
	);
};

export default Login;
