import { Route, Routes } from "react-router-dom";
import "./App.scss";
import Login from "./components/Login/Login";
import Logo from "./components/Logo/Logo";

function App() {
	return (
		<div className="app">
			<header>
				<Logo />
			</header>
			<main className="app__main">
				<Routes>
					<Route index element={<Login />} />
				</Routes>
			</main>
		</div>
	);
}

export default App;
