import "./App.css";
import myImage from "./assets/appmain.png";
import Grid from "@mui/material/Grid";
import { Box as Item } from "@mui/material";

function App() {
  return (
    <>
      <Grid
        container
        sx={{
          backgroundImage: `url(${myImage})`,
          backgroundSize: "cover",
          backgroundPosition: "center",
          minHeight: "90vh",
          color: "green",
          padding: 4,
        }}
      >
        <Item>
          <div>
            <h1>Hello, Dinesh</h1>
            <p>Hope you're having a great day!</p>
            <p>Is Nikhil playing games on his phone?</p>
          </div>
        </Item>
      </Grid>
    </>
  );
}

export default App;
