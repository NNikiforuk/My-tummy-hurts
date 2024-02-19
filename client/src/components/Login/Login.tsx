import { Button } from "../Button";
import { Input } from "../Input";
import { useDispatch, useSelector } from "react-redux";
import { setLoginInputs } from "../../redux/login/inputsLoginSlice";
import { RootState } from "../../redux/store";
import "./login.scss";
import { Link } from "react-router-dom";

const Login = () => {
	const dispatch = useDispatch();
	const inputs = useSelector((state: RootState) => state.inputsLogin);

	const handleChange = (e: any) => {
		dispatch(setLoginInputs({ field: e.target.name, value: e.target.value }));
	};

	const onSubmitForm = () => {};

	return (
		<section className="login">
			<h1>Log in</h1>
			<form onSubmit={onSubmitForm}>
				<div className="login__inputs">
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
				</div>
			</form>
			<Button label="Log in" color="primary" size="small" variant="contained" />
			<div className="login__reroute">
				<div>
					I would need to <Link to="/register">register</Link>
				</div>
			</div>
		</section>
	);
};

export default Login;
