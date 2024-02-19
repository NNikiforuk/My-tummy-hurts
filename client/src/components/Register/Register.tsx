import { Link } from "react-router-dom";
import { Button } from "../Button";
import { Input } from "../Input";
import "../Login/login.scss";
import { useDispatch, useSelector } from "react-redux";
import { RootState } from "../../redux/store";
import { setRegisterInputs } from "../../redux/register/inputsRegisterSlice";

const Register = () => {
	const dispatch = useDispatch();
	const inputs = useSelector((state: RootState) => state.inputsRegister);

	const handleChange = (e: any) => {
		dispatch(
			setRegisterInputs({ field: e.target.name, value: e.target.value })
		);
	};

	const onSubmitForm = () => {};

	return (
		<section className="register">
			<h1>Register</h1>
			<form onSubmit={onSubmitForm}>
				<div className="register__inputs">
					<Input
						type="email"
						name="email"
						placeholder="Enter e-mail"
						value={inputs.email}
						onChange={handleChange}
						label="Email"
					/>
					<Input
						type="text"
						name="name"
						placeholder="Select username"
						value={inputs.email}
						onChange={handleChange}
						label="Username"
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
			<Button label="Register" color="primary" size="small" variant="contained" />
			<div className="register__reroute">
				<div>
					I already have the <Link to="/">account</Link>
				</div>
			</div>
		</section>
	);
};

export default Register;
