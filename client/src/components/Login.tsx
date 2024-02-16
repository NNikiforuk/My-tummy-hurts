import { Button } from "./Button";
import { Input } from "./Input";
import { useDispatch, useSelector } from "react-redux";
import { setInputs } from "../redux/login/inputsSlice";
import { RootState } from "../redux/store";

const Login = () => {
	const dispatch = useDispatch();
	const inputs = useSelector((state: RootState) => state.inputs);

	const handleChange = (e: any) => {
		dispatch(setInputs({ field: e.target.name, value: e.target.value }));
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
					value={inputs.email}
					onChange={handleChange}
					label="Email"
				/>
				<Input
					type="password"
					name="password"
					placeholder="Enter password"
					value={inputs.password}
					onChange={handleChange}
					label="Password"
				/>
			</form>
			<Button label="Log in" color="primary" size="small" variant="contained" />
		</section>
	);
};

export default Login;
