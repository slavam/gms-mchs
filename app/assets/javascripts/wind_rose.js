// import Radar from 'react-d3-radar';
import {Radar} from 'react-chartjs-2';

const WindRoseTable = ({matrix}) => {
  let mns = ["Год","Январь",'','','','','', "Июль"];
  let table = [];
  var rows = [];
  var i;
  for (let j of [0,1,7]){
    rows = [];
    rows.push(<td key="9">{mns[j]}</td>);
    for (i = 0; i < 9; i++) { 
      let index = '['+j+', '+i+']';
      rows.push(<td key={i}>{isNaN(matrix[index]) ? '' : Math.round(matrix[index]) }</td>);
    }
    table.push(<tr key={j}>{rows}</tr>);
  }
  return (
    <table className="table table-hover">
      <thead>
        <tr>
          <th>Период</th>
          <th>С</th>
          <th>СВ</th>
          <th>В</th>
          <th>ЮВ</th>
          <th>Ю</th>
          <th>ЮЗ</th>
          <th>З</th>
          <th>СЗ</th>
          <th>Штиль</th>
        </tr>
      </thead>
      <tbody>{table}</tbody>
    </table>
  );
};

class WindRoseForm extends React.Component{
  constructor(props){
    super(props);
    this.state={
      year: this.props.year,
      cityId: 1
    };
    this.yearChange = this.yearChange.bind(this);
    this.cityChange = this.cityChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  yearChange(e){
    this.setState({year: e.target.value});
  }
  cityChange(value){
    this.setState({cityId: +value});
  }
  handleSubmit(e) {
    e.preventDefault();
    this.props.onFormSubmit(this.state.year, this.state.cityId);
  }
  render(){
    return(
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <input type="number" min="2015" max="2099" step="1" value={this.state.year} onChange={this.yearChange}/>
        <SelectCity cities={this.props.cities} onCityChange={this.cityChange} />
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }
}

class WindRose extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      matrix: this.props.matrix,
      year: this.props.year,
      cityName: this.props.cityName,
      cityId: this.props.cityId,
      canvasImg: null,
      maxValue: this.props.maxValue
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
    this.printHandle = this.printHandle.bind(this);
    this.clickLink = this.clickLink.bind(this);
  }
  clickLink(){
  //   let canvas = document.querySelector('canvas');
	 // let canvasImg = canvas.toDataURL("image/png");

	 // $.ajax({
  //     type: 'POST',
  //     dataType: 'json',
  //     data: {canvas_image: canvasImg}, //, matrix: this.state.matrix},
  //     url: "/measurements/print_wind_rose" //?year="+this.state.year+"&city_name="+this.state.cityName
  //     }).done((data) => {
  //       alert("График сохранен "+data.saved_at);
  //     // }).fail((res) => {
  //     }).fail((xhr, status, error) => {
  //       var err = eval("(" + xhr.responseText + ")");
  //       alert(err.Message);
  //       // this.setState({errors: ["Проблемы с чтением данных из БД"]});
  //     }); 
  
  //   let canvas = document.querySelector('canvas');
	 // let canvasImg = canvas.toDataURL("image/png");
	 // $.ajax({
  //     type: 'POST',
  //     dataType: 'json',
  //     data: {canvas_image: canvasImg},
  //     url: "/measurements/print_wind_rose?year="+this.state.year+"&city_name="+this.state.cityName
  //     }).done((data) => {
  //     }).fail((res) => {
  //       this.setState({errors: ["Проблемы с чтением данных из БД"]});
  //     }); 
    // var delayInMilliseconds = 1000; //1 second

    // setTimeout(function() {
    //   alert("Saved")
    // }, delayInMilliseconds);

  }
  handleFormSubmit(year, cityId){
    this.state.year = year;
    this.state.cityId = cityId;
    let that = this;
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "/measurements/wind_rose?year="+year+"&city_id="+cityId
      }).done((data) => {
        that.setState({matrix: data.matrix, year: data.year, cityName: data.cityName, maxValue: data.maxValue});
      }).fail((res) => {
        that.setState({errors: ["Проблемы с чтением данных из БД"]});
      }); 
      
    // var delayInMilliseconds = 1000; //1 second

    // setTimeout(function() {
    //   let canvas = document.querySelector('canvas');
    //   // this.state.canvasImg = canvas.toDataURL("image/png");
  	 // let canvasImg = canvas.toDataURL("image/png");
  	 // $.ajax({
    //     type: 'POST',
    //     dataType: 'json',
    //     data: {canvas_image: canvasImg},
    //     url: "/measurements/print_wind_rose"
    //     }).done((data) => {
    //     }).fail((res) => {
    //       this.setState({errors: ["Проблемы с чтением данных из БД"]});
    //     });   
    // }, delayInMilliseconds);    
  }
  printHandle(e){
    let canvas = document.querySelector('canvas');
	  let canvasImg = canvas.toDataURL("image/png");
	  $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {canvas_image: canvasImg}, //, matrix: this.state.matrix},
      url: "/measurements/print_wind_rose" //?year="+this.state.year+"&city_name="+this.state.cityName
      }).done((data) => {
        alert("График сохранен. Все готово для печати");
        // var delayInMilliseconds = 1000; //1 second
        // setTimeout(function() {
        //   let that = this;
          // $.ajax({
          //   type: 'GET',
          //   dataType: 'json',
          //   url: "/measurements/wind_rose.pdf?year="+this.state.year+"&city_id="+this.state.cityId
          //   }).done((data) => {
          //   }).fail((res) => {
          //     this.setState({errors: ["Проблемы с чтением данных из БД"]});
          //   }); 
        // }, delayInMilliseconds);    
      }).fail((res) => {
        alert("Проблемы с сохранением графика");
      }); 
      
  }
//     function b64ToUint8Array(b64Image) {
//   var img = atob(b64Image.split(',')[1]);
//   var img_buffer = [];
//   var i = 0;
//   while (i < img.length) {
//       img_buffer.push(img.charCodeAt(i));
//       i++;
//   }
//   return new Uint8Array(img_buffer);
// }

// var b64Image = canvas.toDataURL('image/jpeg');
// var u8Image  = b64ToUint8Array(b64Image);

// var formData = new FormData();
// formData.append("image", new Blob([ u8Image ], {type: "image/jpg"}));

// var xhr = new XMLHttpRequest();
// xhr.open("POST", "/api/upload", true);
// xhr.send(formData);
    
  //   let canvas = document.querySelector('canvas');
	 // //creates image
	 // let canvasImg = canvas.toDataURL("image/jpeg");
	 //// let u8Image  = (canvasImg) => {
  //   function b64ToUint8Array(b64Image) {	 
	 //	  let img = atob(b64Image.split(',')[1]);
  //     let img_buffer = [];
  //     let i = 0;
  //     while (i < img.length) {
  //       img_buffer.push(img.charCodeAt(i));
  //       i++;
  //     }
  //     return new Uint8Array(img_buffer);
	 // }
	 // let u8Image  = b64ToUint8Array(canvasImg);
	 // let formData = new FormData();
  //   formData.append("image", new Blob([ u8Image ], {type: "image/jpg"}));

  //   let xhr = new XMLHttpRequest();
  //   xhr.open("POST", "/tmp", true);
  //   xhr.send(formData);
    
	 // window.open(canvas.toDataURL("image/png"));
    //creates PDF from img
  // 	var doc = new jsPDF('landscape');
  // 	doc.setFontSize(20);
  // 	doc.text(15, 15, "Cool Chart");
  // 	doc.addImage(canvasImg, 'JPEG', 10, 10, 280, 150 );
  // 	doc.save('canvas.pdf');
  // }

  render(){
    const data = {
      labels: ['С', 'СВ', 'В', 'ЮВ', 'Ю', 'ЮЗ', 'З', 'СЗ'],
      datasets: [
        {
          label: 'Год',
          backgroundColor: 'rgba(179,181,198,0.2)',
          borderColor: 'rgba(179,181,198,1)',
          pointBackgroundColor: 'rgba(179,181,198,1)',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: 'rgba(179,181,198,1)',
          data: [
            Math.round(this.state.matrix['[0, 0]']),
            Math.round(this.state.matrix['[0, 1]']),
            Math.round(this.state.matrix['[0, 2]']),
            Math.round(this.state.matrix['[0, 3]']),
            Math.round(this.state.matrix['[0, 4]']),
            Math.round(this.state.matrix['[0, 5]']),
            Math.round(this.state.matrix['[0, 6]']),
            Math.round(this.state.matrix['[0, 7]']),
          ]
        },
        {
          label: 'Январь',
          backgroundColor: 'rgba(55,99,232,0.2)',
          borderColor: 'rgba(55,99,232,1)',
          pointBackgroundColor: 'rgba(55,99,232,1)',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: 'rgba(255,99,132,1)',
          data: [ Math.round(this.state.matrix['[1, 0]']),
            Math.round(this.state.matrix['[1, 1]']),
            Math.round(this.state.matrix['[1, 2]']),
            Math.round(this.state.matrix['[1, 3]']),
            Math.round(this.state.matrix['[1, 4]']),
            Math.round(this.state.matrix['[1, 5]']),
            Math.round(this.state.matrix['[1, 6]']),
            Math.round(this.state.matrix['[1, 7]']),
          ]
        },
        {
          label: 'Июль',
          backgroundColor: 'rgba(255,199,32,0.2)',
          borderColor: 'rgba(255,199,32,1)',
          pointBackgroundColor: 'rgba(255,199,32,1)',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: 'rgba(255,99,132,1)',
          data: [ Math.round(this.state.matrix['[1, 0]']),
            Math.round(this.state.matrix['[7, 1]']),
            Math.round(this.state.matrix['[7, 2]']),
            Math.round(this.state.matrix['[7, 3]']),
            Math.round(this.state.matrix['[7, 4]']),
            Math.round(this.state.matrix['[7, 5]']),
            Math.round(this.state.matrix['[7, 6]']),
            Math.round(this.state.matrix['[7, 7]']),
          ]
        }
      ]
    };
    // let canvas = document.querySelector('canvas');
	  //creates image
	 // let canvasImg = canvas.toDataURL("image/png");
    let desiredLink = "/measurements/wind_rose.pdf?year="+this.state.year+"&city_id="+this.state.cityId; //+"&chart_image="+this.state.canvasImg;
    let radar = this.state.maxValue > 0 ? <div><Radar data={data} width={500}/><br/><button type="button" id="download-pdf" onClick={this.printHandle}>Сохранить график</button><br/><a href={desiredLink} onClick={this.clickLink}>Печать. Сначала сохраните график, пожалуйста</a></div> : '';
    // let canvasImg = '';
    // let canvas = document.querySelector('canvas');
    // if (canvas)
    //   canvasImg = canvas.toDataURL("image/png");
    
    return(
      <div>
        <h1>Повторяемость штилей и направлений ветра по городу {this.state.cityName} по данным наблюдений репрезентативной метеорологической станции за {this.state.year} год</h1>
        <WindRoseTable matrix={this.state.matrix} />
        {/*<a href={desiredLink}>Распечатать</a>*/}
        <h3>Задайте год и город</h3>
        <WindRoseForm year={this.state.year} cities={this.props.cities} onFormSubmit={this.handleFormSubmit}/>
        {radar}
        {/*<button type="button" id="download-pdf" onClick={this.printHandle}>Сохранить график</button>*/}
      </div>
    );
  }
}
export default WindRose;