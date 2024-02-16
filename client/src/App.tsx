import "./App.scss";
import Login from "./components/Login";
import Logo from "./components/Logo/Logo";

function App() {
	return (
		<main className="app">
			<header>
				<Logo />
			</header>
			<Login />
		</main>
	);
}

export default App;
