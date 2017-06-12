const React = require("react");
import Datetime from 'react-datetime';
require('moment/locale/ru');
class InputError extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      message: 'Input is invalid'
    };
  }
  render(){ 
    var errorClass = classNames(this.props.className, {
      'error_container':   true,
      'visible':           this.props.visible,
      'invisible':         !this.props.visible
    });
    return (
      <div className={errorClass}>
        <span>{this.props.errorMessage}</span>
      </div>
    );
  }
}

class ChemOptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      defaultValue: this.props.defaultValue
    };
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    // var name = this.props.name;
    return <select name={this.props.name} onChange={this.handleOptionChange} defaultValue = {this.state.defaultValue}>
      {
        this.props.options.map(function(op) {
          return <option key={op.id} value={op.id}>{op.name}</option>;
        })
      }
    </select>;
  }
}

class InputForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      weather: this.props.weather,
      date: this.props.date,
      term: this.props.term,
      postId: this.props.postId,
      values: {},
      errors: {}
    };
    this.dateChange = this.dateChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleValueChange = this.handleValueChange.bind(this);
    this.get_weather = this.get_weather.bind(this);
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectTerm')
      this.state.term = value;
    else 
      this.state.postId = value;
    this.get_weather();
  }
  get_weather(){
    $.ajax({
      type: 'GET',
      url: "weather_update?date="+this.state.date+"&term="+this.state.term+"&post_id="+this.state.postId
      }).done(function(data) {
        this.setState({
          weather: data.weather
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  handleSubmit(e) {
    e.preventDefault();
    var measurement = {};
    if (!this.state.date || !this.state.term || !this.state.postId ) {
      return;
    }
    measurement.date = this.state.date.trim();
    measurement.post_id = this.state.postId;
    measurement.term = this.state.term;
    // measurement.rhumb
    measurement.wind_direction = this.state.weather.wind_direction;
    measurement.wind_speed = this.state.weather.wind_speed;
    measurement.temperature = this.state.weather.temperature;
    measurement.phenomena = this.state.weather.phenomena;
    measurement.relative_humidity = this.state.weather.relative_humidity;
    measurement.partial_pressure = this.state.weather.partial_pressure;
    measurement.atmosphere_pressure = this.state.weather.atmosphere_pressure;
    // this.props.onParamsSubmit({postId: postId, term: term, date: date});
    $.ajax({
      type: 'POST',
      url: "save_pollutions",
      // url: "save_pollutions?post_id="+this.state.postId+"&date="+this.state.date+"&term="+this.state.term+"&wind_direction="+
      //   this.state.weather.wind_direction+"&wind_speed="+this.state.weather.wind_speed+"&temperature="+this.state.weather.temperature+
      //   "&phenomena="+this.state.weather.phenomena+"&relative_humidity="+this.state.weather.relative_humidity+
      //   "&partial_pressure="+this.state.weather.partial_pressure+"&atmosphere_pressure="+this.state.weather.atmosphere_pressure,
      data: {measurement: measurement, values: this.state.values}
      }).done(function(data) {
        console.log('successfully saved measurement');
        // this.setState({
        //   weather: data.weather
        // });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  handleValueChange(e){
    this.state.values[e.target.name] = e.target.value;
  }
  dateChange(e) {
    var date = e.format("YYYY.MM.DD");
    this.state.date = date;
    this.get_weather();
  }
  
  render(){
    const terms = [
      { id: '01', name: '01' },
      { id: '07', name: '07' },
      { id: '13', name: '13' },
      { id: '19', name: '19' }
    ];
    var self = this;
    var ths = [];
    var tds = [];
    this.props.materials.map(function(m) {
                ths.push(<th key={m.id}>{m.name}</th>);
                tds.push(<td key={m.id}>
                  <input type="text" value={self.state.values[m.id]} onChange={self.handleValueChange} name={m.id} />
                  {/*<InputError visible={self.state[td].errorVisible} errorMessage="Ошибка!" /> */}
                </td>);
              });
    return(
      <form className="pollutionsForm" onSubmit={this.handleSubmit}>
        
        <h3>Данные о погоде</h3>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Температура воздуха</th>
              <th>Скорость ветра</th>
              <th>Направление ветра</th>
              <th>Атмосферное давление</th>
              <th>Относительная влажность</th>
              <th>Атмосферные явления</th>
              <th>Парциальное давление</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                {this.state.weather.temperature}
              </td>
              <td>
                {this.state.weather.wind_speed}
              </td>
              <td>
                {this.state.weather.wind_direction}
              </td>
              <td>
                {this.state.weather.atmosphere_pressure}
              </td>
              <td>
              </td>
              <td>
              </td>
              <td>
              </td>
            </tr>
          </tbody>
        </table>
        <h3>Концентрации веществ</h3>
        <table className="table table-hover">
          <thead>
            <tr>
              {ths}
            </tr>
          </thead>
          <tbody>
            <tr>
              {tds}
            </tr>
          </tbody>
        </table>  
        <div>
          Пост: <ChemOptionSelect options={this.props.posts} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" defaultValue={this.props.postId}/>
          Срок: <ChemOptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerm" defaultValue="07"/>
          Дата: <Datetime timeFormat={false} dateFormat="YYYY.MM.DD" closeOnSelect={true} onChange={this.dateChange} defaultValue={this.props.date} />
        </div>
        <input type="submit" value="Сохранить" />
      </form>
    );
  }
    
}
class InputPollutionsForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      weather: this.props.weather,
      date: this.props.date,
      term: this.props.term,
      postId: this.props.postId,
      errors: {}
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(concentrations) {
    // var that = this;
    // var telegrams = that.state.telegrams;
    // var newTelegrams = [telegram].concat(telegrams);
    // $.ajax({
    //   type: 'POST',
    //   dataType: 'json',
    //   url: "create_synoptic_telegram?t_term="+telegram["Срок"]+"&t_text="+telegram["Телеграмма"]
    //   }).done(function(data) {
    //     // alert(data["Дата"])
    //     newTelegrams[0]["Дата"] = data["Дата"];
    //     that.setState({telegrams: newTelegrams, errors: {}});
    //   }.bind(that))
    //   .fail(function(res) {
    //     that.setState({errors: res.responseJSON.errors});
    //   }.bind(that)); 
  }
  
  render(){
    return(
      <div>
        <InputForm onInputFormSubmit={this.handleFormSubmit} weather = {this.state.weather} errors = {this.state.errors} date={this.state.date} term={this.state.term} materials={this.props.materials} posts={this.props.posts} postId={this.state.postId}/>
      </div>
    );
  }
}
export default InputPollutionsForm;